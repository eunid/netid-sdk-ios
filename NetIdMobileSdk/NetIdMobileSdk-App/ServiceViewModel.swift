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

    func initializeNetIdService(extraClaimShippingAddress: Bool, extraClaimBirthdate: Bool) {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        
        // Initialize configuration for the SDK.
        // It is possible to customize the layer for the permission and login flow to a certain extend.
        // Therefor, PermissionLayerConfig and LoginLayerConfig are used. If they are not set, default vaules will apply instead.
        let loginLayerConfig = LoginLayerConfig()
        let permissionLayerConfig = PermissionLayerConfig()
        let snippetShippingAddress = (extraClaimShippingAddress) ? ", \"shipping_address\": null" : ""
        let snippetBirthdate = (extraClaimBirthdate) ? ", \"birthdate\": null" : ""
        let claims = "{\"userinfo\":{\"email\": {\"essential\": true}, \"email_verified\": {\"essential\": true}\(snippetShippingAddress)\(snippetBirthdate)}}"
                
        let config = NetIdConfig(
            clientId: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6",
            redirectUri: "https://netid-sdk-web.letsdev.de/redirect",
            claims: claims,
            promptWeb: "consent",
            loginLayerConfig: loginLayerConfig,
            permissionLayerConfig: permissionLayerConfig)
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
        NetIdService.sharedInstance.updatePermission(NetIdPermissionUpdate(
            idConsent: .VALID,
            iabTc: "CPdfZIAPdfZIACnABCDECbCkAP_AAAAAAAYgIzJd9D7dbXFDefx_SPt0OYwW0NBXCuQCChSAA2AFVAOQcLQA02EaMATAhiACEQIAolIBAAEEHAFEAECQQIAEAAHsAgSEhAAKIAJEEBEQAAIQAAoKAAAAAAAIgAABoASAmBiQS5bmRUCAOIAQRgBIgggBCIADAgMBBEAIABgIAIIIgSgAAQAAAKIAAAAAARAAAASGgFABcAEMAPwAgoBaQEiAJ2AUiAxgBnwqASAEMAJgAXABHAEcALSAkEBeYDPh0EIABYAFQAMgAcgA-AEAALgAZAA0AB4AD6AIYAigBMACfAFwAXQAxABmADeAHMAPwAhgBLACYAE0AKMAUoAsQBbgDDAGiAPaAfgB-gEDAIoARaAjgCOgEpALEAWmAuYC6gF5AMUAbQA3ABxADnAHUAPQAi8BIICRAE7AKHAXmAwYBjADJAGVAMsAZmAz4BrADiwHjgPrAg0BDkhAbAAWABkAFwAQwAmABcADEAGYAN4AjgBSgCxAIoARwAlIBaQC5gGKANoAc4A6gB6AEggJEAScAz4B45KBAAAgABYAGQAOAAfAB4AEQAJgAXAAxABmADaAIYARwAowBSgC3AH4ARwAk4BaQC6gGKANwAdQBF4CRAF5gMsAZ8A1gCGoSBeAAgABYAFQAMgAcgA8AEAAMgAaAA8gCGAIoATAAngBvADmAH4AQgAhgBHACWAE0AKUAW4AwwB7QD8AP0AgYBFICNAI4ASkAuYBigDaAG4AOIAegBIgCdgFDgKRAXmAwYBkgDPoGsAayA4IB44EOREAYAQwA_AEiAJ2AUiAz4ZAHACGAEwARwBHAEnALzAZ8UgXAALAAqABkADkAHwAgABkADQAHkAQwBFACYAE8AKQAYgAzABzAD8AIYAUYApQBYgC3AGjAPwA_QCLQEcAR0AlIBcwC8gGKANoAbgA9ACLwEiAJOATsAocBeYDGAGSAMsAZ9A1gDWQHBAPHAhm.f_gAAAAAAsgA")
        )
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
        logText.append("netID service user info - fetch finished successfully: \(userInfo)\n")
    }

    public func didFetchUserInfoWithError(_ error: NetIdError) {
        userInfoEnabled = true
        userInfoStatusColor = Color.red
        logText.append("netID service user info - fetch failed: " + error.code.rawValue + "\n")
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
            logText.append("")
        case .PermissionWrite:
            logText.append("")
        }
    }

    public func didFetchPermissions(_ permissions: PermissionReadResponse) {
        logText.append("netID service permission - fetch finished successfully\n")
        switch (permissions.statusCode) {
            case PermissionResponseStatus.PERMISSIONS_FOUND:
                logText.append("Permissions: \(permissions)\n")
            case PermissionResponseStatus.PERMISSIONS_NOT_FOUND:
                logText.append("No permissions found\n")
            default:
                logText.append("This should not happen\n")
        }
        fetchPermissionsEnabled = true
    }

    public func didFetchPermissionsWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError) {
        switch (permissionResponseStatus) {
            case PermissionResponseStatus.NO_TOKEN:
                // no token was passed (handled by SDK should not happen)
                logText.append("No bearer token in request available.\n")
            case PermissionResponseStatus.TOKEN_ERROR:
                // current token expired / is invalid
                logText.append("Token error - token refresh / reauthorization necessary\n")
            case PermissionResponseStatus.TPID_EXISTENCE_ERROR:
                // netID Account was deleted
                logText.append("netID Account was deleted\n")
            case PermissionResponseStatus.TAPP_NOT_ALLOWED:
                // Invalid configuration of client
                logText.append("Client not authorized to use permission management\n")
            case PermissionResponseStatus.PERMISSIONS_NOT_FOUND:
                // Missing permissions
                logText.append("Permissions for tpid not found\n")
            default:
                logText.append("netID service permission - fetch failed with error: \(error.code)\n")
        }
        if (error.msg != nil) {
            logText.append("original error message: \(error.msg!)\n")
        }
        fetchPermissionsEnabled = true
    }

    public func didUpdatePermission(_ subjectIdentifiers: SubjectIdentifiers) {
        logText.append("netID service permission - update finished successfully\n")
        logText.append("Returned: \(subjectIdentifiers)\n")
        updatePermissionEnabled = true
    }

    public func didUpdatePermissionWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError) {
        switch (permissionResponseStatus) {
            case PermissionResponseStatus.NO_TOKEN:
                // no token was passed (handled by SDK should not happen)
                logText.append("No bearer token in request available.\n")
            case PermissionResponseStatus.TOKEN_ERROR:
                // current token expired / is invalid
                logText.append("Token error - token refresh / reauthorization necessary\n")
            case PermissionResponseStatus.TPID_EXISTENCE_ERROR:
                    // netID Account was deleted
                    logText.append("netID Account was deleted\n")
            case PermissionResponseStatus.TAPP_NOT_ALLOWED:
                    // Invalid configuration of client
                    logText.append("Client not authorized to use permission management\n")
            case PermissionResponseStatus.PERMISSION_PARAMETERS_ERROR:
                    // Invalid parameter payload
                    logText.append("Syntactic or semantic error in a permission\n")
            case PermissionResponseStatus.NO_PERMISSIONS:
                    // No permission parameter given
                    logText.append("Parameters are missing. At least one permission must be set.\n")
            case PermissionResponseStatus.NO_REQUEST_BODY:
                    // Request body missing
                    logText.append("Required request body is missing\n")
            case PermissionResponseStatus.JSON_PARSE_ERROR:
                    // Error parsing JSON body
                    logText.append("Invalid JSON body, parse error\n")
            default:
                logText.append("netID service permission - update failed with error: \(error.code)\n")
        }

        if (error.msg != nil) {
            logText.append("original error message: \(error.msg!)\n")
        }
        updatePermissionEnabled = true
    }
    
}
