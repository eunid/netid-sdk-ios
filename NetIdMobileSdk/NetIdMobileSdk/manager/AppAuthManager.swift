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

class AppAuthManager: NSObject {
    private var delegate: AppAuthManagerDelegate?
    private var authConfiguration: OIDServiceConfiguration?
    public var authState: OIDAuthState?
    public var currentAuthorizationFlow: OIDExternalUserAgentSession?

    init(delegate: AppAuthManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }

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

    public func authorizeWeb(presentingViewController: UIViewController) {
        if let serviceConfiguration = authConfiguration, let clientId = NetIdService.sharedInstance.getNedIdConfig()?.clientId,
           let redirectUri = NetIdService.sharedInstance.getNedIdConfig()?.redirectUri {
            if let redirectUri = URL.init(string: redirectUri) {
                let request = OIDAuthorizationRequest.init(configuration: serviceConfiguration,
                        clientId: clientId.uuidString.lowercased(), scopes: [OIDScopeOpenID, OIDScopeProfile],
                        redirectURL: redirectUri, responseType: OIDResponseTypeCode, additionalParameters: nil)
                currentAuthorizationFlow =
                        OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { authState, error in
                            if let authState = authState {
                                self.authState = authState
                                Logger.shared.debug("Got authorization tokens. Access token: " +
                                        "\(authState.lastTokenResponse?.idToken ?? "nil")")
                                self.delegate?.didFinishAuthenticationWithError(nil)
                            } else {
                                Logger.shared
                                        .error("Authorization with clientID: \(clientId) and redirectUri: \(redirectUri) failed with error: \(error?.localizedDescription ?? "Unknown error")")
                                self.authState = nil
                                self.delegate?.didFinishAuthenticationWithError(
                                        NetIdError(code: NetIdErrorCode.NoAuth, process: NetIdErrorProcess.Authentication))
                            }
                        }
            }
        }
    }

    public func fetchUserInfo() {
        if let host = NetIdService.sharedInstance.getNedIdConfig()?.host, let accessToken = authState?.lastTokenResponse?.accessToken {
            let userInfoRequest = UserInfoRequest(host: host, accessToken: accessToken)
            Webservice.shared.performRequest(userInfoRequest, callback: { data, error in
                guard let data = data else {
                    self.delegate?.didFetchUserInfoWithError(NetIdError(code: .Unknown, process: .UserInfo)
                    )
                    return
                }

                if let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
                    self.delegate?.didFetchUserInfo(userInfo)
                } else {
                    self.delegate?.didFetchUserInfoWithError(NetIdError(code: .JsonDeserializationError, process: .UserInfo))
                }
            })
        } else {
            delegate?.didFetchUserInfoWithError(NetIdError(code: .NoAuth, process: .UserInfo))
        }
    }

    public func endSession() {
        authState = nil
        currentAuthorizationFlow = nil
        delegate?.didEndSession()
    }
}
