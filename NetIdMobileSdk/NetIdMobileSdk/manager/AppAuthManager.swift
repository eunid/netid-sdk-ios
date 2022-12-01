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
    public let permissionManagementScope = "permission_management"
    private var netIdConfig: NetIdConfig?
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
         authState?.lastTokenResponse?.accessToken
    }

    public func getPermissionToken() -> String? {
        // Fallback for getting a permission token as long as there is no refresh token flow (and only permission scope was requested).
        guard let token = getAuthState()?.lastTokenResponse?.idToken else {
            return getAccessToken()
        }
        return TokenUtil.getPermissionTokenFrom(token)
    }

    public func getAuthState() -> OIDAuthState? {
        return authState
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
        var claims = netIdConfig?.claims
        
        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
            claims = nil
        case .Login:
            scopes.append(OIDScopeOpenID)
        case .LoginPermission:
            scopes.append(permissionManagementScope)
            scopes.append(OIDScopeOpenID)
        }
        if let serviceConfiguration = authConfiguration, let clientId = netIdConfig?.clientId,
           let redirectUri = netIdConfig?.redirectUri {
            if let redirectUri = URL.init(string: redirectUri) {
                let request = OIDAuthorizationRequest.init(configuration: serviceConfiguration,
                        clientId: clientId, scopes: scopes,
                        redirectURL: redirectUri, responseType: OIDResponseTypeCode, additionalParameters: claims)
                currentAuthorizationFlow =
                        OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [self] authState, error in
                            if let authState = authState {
                                self.authState = authState
                                Logger.shared.debug("Got authorization tokens. Access token: " +
                                        "\(authState.lastTokenResponse?.accessToken ?? "nil")")

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
        var claims = netIdConfig?.claims
        
        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
            claims = nil
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
                    let request = OIDAuthorizationRequest.init(
                        configuration: serviceConfiguration,
                        clientId: clientId, scopes: scopes,
                        redirectURL: redirectUri,
                        responseType: OIDResponseTypeCode,
                        additionalParameters: claims)
                    
                    currentAuthorizationFlow =
                    OIDAuthState.authState(byPresenting: request, externalUserAgent: agent) { [self] authState, error in
                                if let authState = authState {
                                    self.authState = authState
                                    Logger.shared.debug("Got authorization tokens. Access token: " +
                                            "\(authState.lastTokenResponse?.accessToken ?? "nil")")
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
        delegate?.didEndSession()
    }
}
