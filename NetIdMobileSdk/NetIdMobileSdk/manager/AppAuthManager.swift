// Copyright 2022 European netID Foundation (https://enid.foundation)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import AppAuth
import UIKit

/**
 AppAuthManager is responsible for the communication to the AppAuth library.
 */
class AppAuthManager: NSObject {
    private weak var delegate: AppAuthManagerDelegate?
    public var authConfiguration: OIDServiceConfiguration?
    public var authState: OIDAuthState?
    public var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private let permissionManagementScope = "permission_management"
    private let keyClaims = "claims"
    private let keyPrompt = "prompt"
    private var netIdConfig: NetIdConfig?
    private let STORE_NAME = "netIdSdk"
    private let KEY_STATE = "authState"
    private let agent = IdAppAgent()

    init(delegate: AppAuthManagerDelegate?, netIdConfig: NetIdConfig?) {
        self.delegate = delegate
        self.netIdConfig = netIdConfig
        super.init()
    }

    init(delegate: AppAuthManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }

    public func getAccessToken() -> String? {
        getAuthState()?.lastTokenResponse?.accessToken
    }

    public func getPermissionToken() -> String? {
        // Fallback for getting a permission token as long as there is no refresh token flow (and only permission scope was requested).
        guard let token = getAuthState()?.lastTokenResponse?.idToken else {
            return getAccessToken()
        }
        return TokenUtil.getPermissionTokenFrom(token)
    }

    public func getAuthState() -> OIDAuthState? {
        if (authState != nil) {
            return authState
        }
        
        authState = readState()
        return authState
    }

    /**
     Read auth state from shared preferences if available.
     If there is no state or if the state can not be reconstructed, null is returned.
     - Returns return the read auth state or null if there is none
     */
    private func readState() -> OIDAuthState? {
        if let data = UserDefaults(suiteName: STORE_NAME)?.object(forKey: KEY_STATE) as? Data {
            if let savedAuthState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState {
                return savedAuthState
            }
        }
        return nil
    }

    /**
     Write current auth state to shared preferences.
     If the given state is null, remove the currently stored state.
     - Parameter authState the state to persist or null to remove from store
     */
    private func writeState() {
        var data: Data? = nil
        if let authState = self.authState {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
                if let userDefaults = UserDefaults(suiteName: STORE_NAME) {
                    userDefaults.set(data, forKey: KEY_STATE)
                    userDefaults.synchronize()
                }
            } catch {
                Logger.shared.debug("Failure writing authState to preferences.")
            }
        } else {
            if let userDefaults = UserDefaults(suiteName: STORE_NAME) {
                userDefaults.removeObject(forKey: KEY_STATE)
                userDefaults.synchronize()
            }
        }
    }
    
    /**
     Fetches the discovery document which includes the configuration for the authentication endpoints.
     - Parameter host: server address
     */
    public func fetchConfiguration(_ host: String) {
        var urlComponents = URLComponents()
        urlComponents.host = host
        urlComponents.scheme = WebserviceConstants.PROTOCOL
        if let url = urlComponents.url {
            OIDAuthorizationService.discoverConfiguration(forIssuer: url) { [self] configuration, error in
                if error == nil {
                    authConfiguration = configuration
                    delegate?.didFinishInitializationWithError(nil)
                } else {
                    delegate?.didFinishInitializationWithError(
                            NetIdError(code: .InvalidDiscoveryDocument, process: .Configuration))
                }
            }
        }
    }

    /**
     Starts the app2web authorization process.
     - Parameter presentingViewController: needed to present the authorization WebView
     - Parameter authFlow: specifies, which auth flow to use
     */
    public func authorizeWeb(presentingViewController: UIViewController, authFlow: NetIdAuthFlow) {
        var scopes: [String] = []
        var additionalParameters = [keyClaims: netIdConfig?.claims ?? ""]
        if (netIdConfig?.promptWeb != nil) {
            additionalParameters[keyPrompt] = netIdConfig?.promptWeb
        }

        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
            additionalParameters.removeValue(forKey: keyClaims)
        case .Login:
            scopes.append(OIDScopeOpenID)
        case .LoginPermission:
            scopes.append(permissionManagementScope)
            scopes.append(OIDScopeOpenID)
        }
        if let serviceConfiguration = authConfiguration, let clientId = netIdConfig?.clientId,
           let redirectUri = netIdConfig?.redirectUri {
            if let redirectUri = URL.init(string: redirectUri) {
                let request = OIDAuthorizationRequest.init(
                    configuration: serviceConfiguration,
                    clientId: clientId,
                    scopes: scopes,
                    redirectURL: redirectUri,
                    responseType: OIDResponseTypeCode,
                    additionalParameters: additionalParameters)

                if (authState != nil) {
                    self.delegate?.didFinishAuthenticationWithError(nil)
                }

                currentAuthorizationFlow =
                        OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [self] authState, error in
                            if let authState = authState {
                                self.authState = authState
                                Logger.shared.debug("Got authorization tokens. Access token: " +
                                        "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                                writeState()
                                self.delegate?.didFinishAuthenticationWithError(nil)
                            } else {
                                Logger.shared
                                        .error("Authorization with clientID: \(clientId) and redirectUri: \(redirectUri) failed with error: \(error?.localizedDescription ?? "Unknown error")")
                                self.delegate?.didFinishAuthenticationWithError(
                                        NetIdError(code: NetIdErrorCode.NoAuth, process: NetIdErrorProcess.Authentication))
                            }
                        }
            }
        }
    }
    
    /**
     Starts the app2app authorization process.
     - Parameter universalLink: universal link to call for redirecting to id app
     - Parameter authFlow: specifies, which auth flow to use
     */
    public func authorizeApp(universalLink: URL, authFlow: NetIdAuthFlow) {
        var scopes: [String] = []
        var additionalParameters = [keyClaims: netIdConfig?.claims ?? ""]

        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
            additionalParameters.removeValue(forKey: keyClaims)
        case .Login:
            scopes.append(OIDScopeOpenID)
        case .LoginPermission:
            scopes.append(permissionManagementScope)
            scopes.append(OIDScopeOpenID)
        }
        if let serviceConfiguration = authConfiguration,
            let clientId = netIdConfig?.clientId,
            let redirectUri = netIdConfig?.redirectUri {
                if let redirectUri = URL.init(string: redirectUri) {
                    let appServiceConfiguration = OIDServiceConfiguration.init(
                                    authorizationEndpoint: universalLink,
                                    tokenEndpoint: serviceConfiguration.tokenEndpoint,
                                    issuer: serviceConfiguration.issuer)
                    
                    let request = OIDAuthorizationRequest.init(
                        configuration: appServiceConfiguration,
                        clientId: clientId,
                        scopes: scopes,
                        redirectURL: redirectUri,
                        responseType: OIDResponseTypeCode,
                        additionalParameters: additionalParameters)
                    
                    // Make sure there is no dangling session before using the agent.
                    agent.dismiss(animated: false, completion: {})
                    currentAuthorizationFlow =
                    OIDAuthState.authState(byPresenting: request, externalUserAgent: agent) { [self] authState, error in
                                if let authState = authState {
                                    self.authState = authState
                                    Logger.shared.debug("Got authorization tokens. Access token: " +
                                            "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                                    writeState()
                                    self.delegate?.didFinishAuthenticationWithError(nil)
                                } else {
                                    Logger.shared
                                            .error("Authorization with clientID: \(clientId) and redirectUri: \(redirectUri) failed with error: \(error?.localizedDescription ?? "Unknown error")")
                                    self.delegate?.didFinishAuthenticationWithError(
                                            NetIdError(code: NetIdErrorCode.NoAuth, process: NetIdErrorProcess.Authentication))
                                }
                            }
                }
        }
    }
        
    public func endSession() {
        authState = nil
        currentAuthorizationFlow = nil
        agent.dismiss(animated: false, completion: {})
        writeState()
        delegate?.didEndSession()
    }
}
