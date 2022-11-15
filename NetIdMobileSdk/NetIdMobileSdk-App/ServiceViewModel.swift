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

    @Published var logText = ""
    @Published var authFlow: NetIdAuthFlow = .Permission

    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        
        // Initialize configuration for the SDK.
        // It is possible to customize the layer for the permission and login flow to a certain extend.
        // Therefor, PermissionLayerConfig and LoginLayerConfig are used. If they are not set, default vaules will apply instead.
        let loginLayerConfig = LoginLayerConfig()
        let permissionLayerConfig = PermissionLayerConfig()
        var claims = Dictionary<String, String>()
        claims["claims"] = "{\"userinfo\":{\"email\": {\"essential\": true}, \"email_verified\": {\"essential\": true}}}"
        let config = NetIdConfig(host: "broker.netid.de", clientId: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6",
                redirectUri: "https://netid-sdk-web.letsdev.de/redirect", 
                claims: claims, loginLayerConfig: loginLayerConfig, permissionLayerConfig: permissionLayerConfig)
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
        NetIdService.sharedInstance.fetchPermissions(collapseSyncId: false)
    }

    func updatePermission() {
        updatePermissionEnabled = false
        // these values are only for demonstration purpose
        NetIdService.sharedInstance.updatePermission(NetIdPermissionUpdate(idConsent: "VALID",
                iabTc: "CPdfZIAPdfZIACnABCDECbCkAP_AAAAAAAYgIzJd9D7dbXFDefx_SPt0OYwW0NBXCuQCChSAA2AFVAOQcLQA02EaMATAhiACEQIAolIBAAEEHAFEAECQQIAEAAHsAgSEhAAKIAJEEBEQAAIQAAoKAAAAAAAIgAABoASAmBiQS5bmRUCAOIAQRgBIgggBCIADAgMBBEAIABgIAIIIgSgAAQAAAKIAAAAAARAAAASGgFABcAEMAPwAgoBaQEiAJ2AUiAxgBnwqASAEMAJgAXABHAEcALSAkEBeYDPh0EIABYAFQAMgAcgA-AEAALgAZAA0AB4AD6AIYAigBMACfAFwAXQAxABmADeAHMAPwAhgBLACYAE0AKMAUoAsQBbgDDAGiAPaAfgB-gEDAIoARaAjgCOgEpALEAWmAuYC6gF5AMUAbQA3ABxADnAHUAPQAi8BIICRAE7AKHAXmAwYBjADJAGVAMsAZmAz4BrADiwHjgPrAg0BDkhAbAAWABkAFwAQwAmABcADEAGYAN4AjgBSgCxAIoARwAlIBaQC5gGKANoAc4A6gB6AEggJEAScAz4B45KBAAAgABYAGQAOAAfAB4AEQAJgAXAAxABmADaAIYARwAowBSgC3AH4ARwAk4BaQC6gGKANwAdQBF4CRAF5gMsAZ8A1gCGoSBeAAgABYAFQAMgAcgA8AEAAMgAaAA8gCGAIoATAAngBvADmAH4AQgAhgBHACWAE0AKUAW4AwwB7QD8AP0AgYBFICNAI4ASkAuYBigDaAG4AOIAegBIgCdgFDgKRAXmAwYBkgDPoGsAayA4IB44EOREAYAQwA_AEiAJ2AUiAz4ZAHACGAEwARwBHAEnALzAZ8UgXAALAAqABkADkAHwAgABkADQAHkAQwBFACYAE8AKQAYgAzABzAD8AIYAUYApQBYgC3AGjAPwA_QCLQEcAR0AlIBcwC8gGKANoAbgA9ACLwEiAJOATsAocBeYDGAGSAMsAZ9A1gDWQHBAPHAhm.f_gAAAAAAsgA"),
                collapseSyncId: false)
    }

    func resumeSession(_ url: URL) {
        NetIdService.sharedInstance.resumeSession(url)
    }

    func endSession() {
        endSessionEnabled = false
        NetIdService.sharedInstance.endSession()
    }

    @ViewBuilder
    func getAuthorizationView() -> some View {
        if let currentViewController = UIApplication.shared.visibleViewController {
            NetIdService.sharedInstance.getAuthorizationView(currentViewController: currentViewController,
                    authFlow: authFlow)
        } else {
            EmptyView()
        }
    }
}

extension ServiceViewModel: NetIdServiceDelegate {

    func didFinishInitializationWithError(_ error: NetIdError?) {
        if let errorCode = error?.code.rawValue {
            initializationStatusColor = Color.red
            logText.append("netID service initialization failed \n" + errorCode + "\n")
        } else {
            initializationStatusColor = Color.green
            logText.append("netID service initialized successfully\n")
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
        logText.append("netID service authorized successfully\n" + accessToken + "\n")
    }

    func didFinishAuthenticationWithError(_ error: NetIdError?) {
        withAnimation {
            authorizationViewVisible = false
        }
        authenticationStatusColor = Color.red
        if let errorCode = error?.code.rawValue {
            authenticationStatusColor = Color.red
            logText.append("netID service authorization failed: " + errorCode + "\n")
            authenticationEnabled = true
        } else {
            authenticationStatusColor = Color.green
            logText.append("netID service authorization successfully\n")
        }
    }

    public func didFetchUserInfo(_ userInfo: UserInfo) {
        userInfoStatusColor = Color.green
        userInfoEnabled = true
        logText.append("Fetched user info successfully: \(userInfo.description)\n")
    }

    public func didFetchUserInfoWithError(_ error: NetIdError) {
        userInfoEnabled = true
        userInfoStatusColor = Color.red
        logText.append("User info fetch failed: " + error.code.rawValue + "\n")
    }

    public func didEndSession() {
        logText.append("netID service did end session successfully\n")
        authenticationStatusColor = Color.gray
        userInfoStatusColor = Color.gray
        authenticationEnabled = true
        userInfoEnabled = false
        updatePermissionEnabled = false
        fetchPermissionsEnabled = false
    }

    func didEncounterNetworkError(_ error: NetIdError) {
        logText.append("netID service did encounter a network error in process: \(error.process)\n")
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
        logText.append("netID service user did cancel authentication in process: \(error.process)\n")
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

    public func didFetchPermissionsWithError(_ error: NetIdError, originalError: Error?) {
        logText.append("didFetchPermissionsWithError \(error.code.rawValue)\n")
        if (originalError != nil) {
            logText.append("original error message: \(originalError!.localizedDescription)\n")
        }
        fetchPermissionsEnabled = true
    }

    public func didUpdatePermission() {
        logText.append("didUpdatePermission \n")
        updatePermissionEnabled = true
    }

    public func didUpdatePermissionWithError(_ error: NetIdError, originalError: Error?) {
        logText.append("didUpdatePermissionWithError \(error.code.rawValue)\n")
        if (originalError != nil) {
            logText.append("original error message: \(originalError!.localizedDescription)\n")
        }
        updatePermissionEnabled = true
    }

    public func didTransmitInvalidToken() {
        logText.append("didTransmitInvalidToken \n")

    }
}
