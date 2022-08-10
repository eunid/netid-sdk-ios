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
    @Published var fetchPermissionsEnabled = false
    @Published var updatePermissionEnabled = false

    @Published var authorizationViewVisible = false

    @Published var initializationStatusColor = Color.gray
    @Published var authenticationStatusColor = Color.gray
    @Published var userInfoStatusColor = Color.gray

    @Published var logText = "Logs:\n\n"

    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        let config = NetIdConfig(host: "broker.netid.de", clientId: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6",
                redirectUri: "de.netid.mobile.sdk.NetIdMobileSdk:/oauth2redirect/example-provider", originUrlScheme: "netIdExample")
        NetIdService.sharedInstance.initialize(config)
    }

    func authorizeNetIdService() {
        authenticationEnabled = false
        withAnimation {
            authorizationViewVisible = true
        }
    }

    func fetchUserInfo() {
        userInfoEnabled = false
        NetIdService.sharedInstance.fetchUserInfo()
    }

    func fetchPermissions() {
        fetchPermissionsEnabled = false
        NetIdService.sharedInstance.fetchPermissions()
    }

    func updatePermission() {
        updatePermissionEnabled = false
        NetIdService.sharedInstance.updatePermission(NetIdPermissionUpdate(idConsent: "", iabTc: ""))
    }

    func endSession() {
        endSessionEnabled = false
        NetIdService.sharedInstance.endSession()
    }

    @ViewBuilder
    func getAuthorizationView() -> some View {
        if let currentViewController = UIApplication.shared.visibleViewController {
            NetIdService.sharedInstance.getAuthorizationView(currentViewController: currentViewController)
        } else {
            EmptyView()
        }
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
        withAnimation {
            authorizationViewVisible = false
        }
        authenticationStatusColor = Color.green
        userInfoEnabled = true
        endSessionEnabled = true
        updatePermissionEnabled = true
        fetchPermissionsEnabled = true
        logText.append("Net ID service authorized successfully\n" + accessToken + "\n")
    }

    func didFinishAuthenticationWithError(_ error: NetIdError?) {
        withAnimation {
            authorizationViewVisible = false
        }
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
            case .PermissionRead:
                //TODO
                self.logText.append("")
            case .PermissionWrite:
                //TODO
                self.logText.append("")
            }
        })
        UIApplication.shared.visibleViewController?.present(alert, animated: true)
    }

    public func didCancelAuthentication(_ error: NetIdError) {
        logText.append("Net ID service user did cancel authentication in process: \(error.process)\n")
        withAnimation {
            authorizationViewVisible = false
        }
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
        case .PermissionRead:
            //TODO
            logText.append("")
        case .PermissionWrite:
            //TODO
            logText.append("")
        }
    }

    public func didFetchPermissions(_ permissions: Permissions) {
        logText.append("didFetchPermissions \(permissions.description) \n")
        fetchPermissionsEnabled = true
    }

    public func didFetchPermissionsWithError(_ error: NetIdError) {
        logText.append("didFetchPermissionsWithError \(error.code.rawValue)\n")
        fetchPermissionsEnabled = true
    }

    public func didUpdatePermission() {
        logText.append("didUpdatePermission \n")
        updatePermissionEnabled = true
    }

    public func didUpdatePermissionWithError(_ error: NetIdError) {
        logText.append("didUpdatePermissionWithError \(error.code.rawValue)\n")
        updatePermissionEnabled = true
    }
}
