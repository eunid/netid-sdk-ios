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
    private var authConfiguration: OIDServiceConfiguration?
    public var authState: OIDAuthState?
    public var currentAuthorizationFlow: OIDExternalUserAgentSession?
    public let permissionManagementScope = "permission_management"
    private var idToken: String?
    private var netIdConfig: NetIdConfig?

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

    public func getIdToken() -> String? {
        idToken
    }

    public func setIdToken(_ token: String) {
        idToken = token
    }

    public func getPermissionToken() -> String? {
        guard let token = getIdToken() else {
            return nil
        }
        return TokenUtil.getPermissionTokenFrom(token)
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
     Starts the web authorization process.
     - Parameter presentingViewController: needed to present the authorization WebView
     */
    public func authorizeWeb(presentingViewController: UIViewController, authFlow: NetIdAuthFlow) {
        var scopes: [String] = []
        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
        case .Login:
            scopes.append(OIDScopeOpenID)
            scopes.append(OIDScopeProfile)
        case .LoginPermission:
            scopes.append(permissionManagementScope)
            scopes.append(OIDScopeOpenID)
            scopes.append(OIDScopeProfile)
        }
        if let serviceConfiguration = authConfiguration, let clientId = netIdConfig?.clientId,
           let redirectUri = netIdConfig?.redirectUri {
            if let redirectUri = URL.init(string: redirectUri) {
                let request = OIDAuthorizationRequest.init(configuration: serviceConfiguration,
                        clientId: clientId, scopes: scopes,
                        redirectURL: redirectUri, responseType: OIDResponseTypeCode, additionalParameters: netIdConfig?.claims)
                currentAuthorizationFlow =
                        OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [self] authState, error in
                            if let authState = authState {
                                self.authState = authState
                                idToken = authState.lastTokenResponse?.idToken
                                Logger.shared.debug("Got authorization tokens. Access token: " +
                                        "\(authState.lastTokenResponse?.idToken ?? "nil")")

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
    
    public func getAuthRequestForUrl(url: URL, authFlow: NetIdAuthFlow) -> URL? {
        var scopes: [String] = []
//        scopes.append(OIDScopeProfile)

        switch authFlow {
        case .Permission:
            scopes.append(permissionManagementScope)
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
                                                           redirectURL: redirectUri, responseType: OIDResponseTypeCode, additionalParameters: netIdConfig?.claims)
                var components = URLComponents(string: request.externalUserAgentRequestURL().absoluteString)
                components?.host = url.host
                components?.path = url.path
                return components?.url
            }
        }
        return nil
    }

    public func endSession() {
        authState = nil
        currentAuthorizationFlow = nil
        delegate?.didEndSession()
    }
}
