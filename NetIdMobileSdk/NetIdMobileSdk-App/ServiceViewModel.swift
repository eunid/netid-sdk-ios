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
import NetIdMobileSdk
import SwiftUI

class ServiceViewModel: NSObject, ObservableObject {

    @Published var initializationEnabled = true
    @Published var authenticationEnabled = false
    @Published var userInfoEnabled = false
    @Published var endSessionEnabled = false

    @Published var initializationStatusColor = Color.gray
    @Published var authenticationStatusColor = Color.gray
    @Published var userInfoStatusColor = Color.gray

    @Published var logText = "Logs:\n\n"

    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        if let clientID = UUID(uuidString: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6") {
            let config = NetIdConfig(host: "broker.netid.de", clientId: clientID,
                    redirectUri: "de.netid.mobile.sdk.NetIdMobileSdk:/oauth2redirect/example-provider")
            NetIdService.sharedInstance.initialize(config)
        }
    }

    func authorizeNetIdService() {
        authenticationEnabled = false
        if let currentViewController = UIApplication.shared.visibleViewController {
            currentViewController.present(
                    NetIdService.sharedInstance.getAuthorizationViewController(currentViewController: currentViewController),
                    animated: true)
        }
    }

    func fetchUserInfo() {
        userInfoEnabled = false
        NetIdService.sharedInstance.fetchUserInfo()
    }

    func endSession() {
        endSessionEnabled = false
        NetIdService.sharedInstance.endSession()
    }
}

extension ServiceViewModel: NetIdServiceDelegate {

    func didFinishInitializationWithError(_ error: NetIdError?) {
        if let errorCode = error?.code.rawValue {
            initializationStatusColor = Color.red
            logText.append("Net ID service initialization failed \n" + errorCode + "\n")
        } else {
            initializationStatusColor = Color.green
            logText.append("Net ID service initialized successfully\n")
            authenticationEnabled = true
        }
    }

    func didFinishAuthentication(_ accessToken: String) {
        authenticationStatusColor = Color.green
        userInfoEnabled = true
        endSessionEnabled = true
        logText.append("Net ID service authorized successfully\n" + accessToken + "\n")
    }

    func didFinishAuthenticationWithError(_ error: NetIdError?) {
        authenticationStatusColor = Color.red
        if let errorCode = error?.code.rawValue {
            authenticationStatusColor = Color.red
            logText.append("Net ID service authorization failed: " + errorCode + "\n")
            authenticationEnabled = true
        } else {
            authenticationStatusColor = Color.green
            logText.append("Net ID service authorization successfully\n")
        }
    }

    public func didFetchUserInfo(_ userInfo: UserInfo) {
        userInfoStatusColor = Color.green
        userInfoEnabled = true
        logText.append("Fetched user info successfully: \(userInfo.description)")
    }

    public func didFetchUserInfoWithError(_ error: NetIdError) {
        userInfoEnabled = true
        userInfoStatusColor = Color.red
        logText.append("User info fetch failed: " + error.code.rawValue + "\n")
    }

    public func didEndSession() {
        logText.append("Net ID service did end session successfully\n")
        authenticationStatusColor = Color.gray
        userInfoStatusColor = Color.gray
        authenticationEnabled = true
        userInfoEnabled = false
    }

    func didEncounterNetworkError(_ error: NetIdError) {
        logText.append("Net ID service did encounter a network error in process: \(error.process)\n")
        let alert = UIAlertController(title: NSLocalizedString("network_error_alert_title", comment: ""),
                message: NSLocalizedString("network_error_alert_description", comment: ""),
                preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("network_error_alert_action", comment: ""), style: .default) { _ in
            alert.dismiss(animated: true)
            switch error.process {
            case .Configuration:
                self.initializationStatusColor = Color.red
                self.initializationEnabled = true
            case .Authentication:
                self.authenticationStatusColor = Color.red
                self.authenticationEnabled = true
            case .UserInfo:
                self.userInfoStatusColor = Color.red
                self.userInfoEnabled = true
            }
        })
        UIApplication.shared.visibleViewController?.present(alert, animated: true)
    }

    public func didCancelAuthentication(_ error: NetIdError) {
        logText.append("Net ID service user did cancel authentication in process: \(error.process)\n")
        switch error.process {
        case .Configuration:
            initializationStatusColor = Color.yellow
            initializationEnabled = true
        case .Authentication:
            authenticationStatusColor = Color.yellow
            authenticationEnabled = true
        case .UserInfo:
            userInfoStatusColor = Color.yellow
            userInfoEnabled = true
        }
    }
}
