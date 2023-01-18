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

    @Published var logText = ""
    @Published var authFlow: NetIdAuthFlow = .Permission

    override init() {
        super.init()
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)

        // Initialize configuration for the SDK.
        // It is possible to customize the layer for the permission and login flow to a certain extend.
        // Therefor, PermissionLayerConfig and LoginLayerConfig are used. If they are not set, default vaules will apply instead.
        let loginLayerConfig = LoginLayerConfig()
        let permissionLayerConfig = PermissionLayerConfig()
        let claims = "{\"userinfo\":{\"email\": {\"essential\": true}, \"email_verified\": {\"essential\": true}}}"
        let config = NetIdConfig(
            clientId: "2f9d690d-9a48-4e9d-a8b8-9a8866b621f2",
            redirectUri: "https://eunid.github.io/redirectApp",
            claims: claims,
            promptWeb: "consent",
            loginLayerConfig: loginLayerConfig,
            permissionLayerConfig: permissionLayerConfig)
        NetIdService.sharedInstance.initialize(config)
        
        // If there has been an old, saved session, we end it first.
        // That way we always have a clear but initialized environment.
        NetIdService.sharedInstance.endSession()
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

    func resumeSession(_ url: URL) {
        NetIdService.sharedInstance.resumeSession(url)
    }

    func endSession() {
        endSessionEnabled = false
        NetIdService.sharedInstance.endSession()
    }
}

extension ServiceViewModel: NetIdServiceDelegate {

    func didFinishInitializationWithError(_ error: NetIdError?) {
        if let errorCode = error?.code.rawValue {
            logText.append("netID service initialization failed \n" + errorCode + "\n")
        } else {
            logText.append("netID service initialized successfully\n")
            authenticationEnabled = true
        }
    }

    func didFinishAuthentication(_ accessToken: String) {
        withAnimation {
            authorizationViewVisible = false
        }
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
        if let errorCode = error?.code.rawValue {
            logText.append("netID service authorization failed: " + errorCode + "\n")
            authenticationEnabled = true
        } else {
            logText.append("netID service authorization successfully\n")
        }
    }

    public func didFetchUserInfo(_ userInfo: UserInfo) {
        userInfoEnabled = true
        logText.append("netID service user info - fetch finished successfully: \(userInfo)\n")
    }

    public func didFetchUserInfoWithError(_ error: NetIdError) {
        userInfoEnabled = true
        logText.append("netID service user info - fetch failed: " + error.code.rawValue + "\n")
    }

    public func didEndSession() {
        logText.append("netID service did end session successfully\n")
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
                self.initializationEnabled = true
            case .Authentication:
                self.authenticationEnabled = true
            case .UserInfo:
                self.userInfoEnabled = true
            case .PermissionRead:
                //TODO
                self.logText.append("")
            case .PermissionWrite:
                //TODO
                self.logText.append("")
            }
        })
    }

    public func didCancelAuthentication(_ error: NetIdError) {
        logText.append("netID service user did cancel authentication in process: \(error.process)\n")
        withAnimation {
            authorizationViewVisible = false
        }
        switch error.process {
        case .Configuration:
            initializationEnabled = true
        case .Authentication:
            authenticationEnabled = true
        case .UserInfo:
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
