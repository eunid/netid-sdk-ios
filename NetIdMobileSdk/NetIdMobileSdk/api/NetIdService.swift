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
import UIKit
import SwiftUI

open class NetIdService: NSObject {

    public static let sharedInstance = NetIdService()
    private var netIdConfig: NetIdConfig?
    private var netIdListener: [NetIdServiceDelegate] = []
    private var appAuthManager: AppAuthManager?
    private var userInfoManager: UserInfoManager?
    private var permissionManager: PermissionManager?

    /**
      Registers a new listener of type NetIdServiceDelegate
     - Parameter listener: the new listener
     */
    public func registerListener(_ listener: NetIdServiceDelegate) {
        netIdListener.append(listener)
    }

    /**
     Initializes the SDK and loads the authentication configuration document.
     - Parameter netIdConfig: the client configuration of type ``NetIdConfig``.
     */
    public func initialize(_ netIdConfig: NetIdConfig) {
        if handleConnection(.Configuration) {
            if self.netIdConfig != nil {
                Logger.shared.debug("Configuration already been set.")
            } else {
                self.netIdConfig = netIdConfig
                Font.loadCustomFonts()
                userInfoManager = UserInfoManager(delegate: self)
                permissionManager = PermissionManager(delegate: self)
                appAuthManager = AppAuthManager(delegate: self, netIdConfig: netIdConfig)
                appAuthManager?.fetchConfiguration(netIdConfig.host)
            }
        }
    }

    /**
     Provides the currently stored NetIdConfig.
     - Returns:
     */
    public func getNedIdConfig() -> NetIdConfig? {
        netIdConfig
    }

    /**
     Ability to set a token for the SDK.
     - Parameter token: the token to set.
     - Returns:
     */
    public func transmitToken(_ token: String) {
        if TokenUtil.isValidJwtToken(token) {
            appAuthManager?.setIdToken(token)
        } else {
            for item in netIdListener {
                item.didTransmitInvalidToken()
            }
        }
    }
    
    /**
     Resumes a session when coming back from external authorization agent.
     - Parameter url: callback url
     */
    public func resumeSession(_ url: URL) {
        guard let _ = appAuthManager, ((appAuthManager?.currentAuthorizationFlow) != nil) else {
            return
        }
        appAuthManager?.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url)
    }

    /**
     Provides the view controller
     - Parameter currentViewController:
     - Parameter authFlow:
     - Returns:
     */
    public func getAuthorizationView(currentViewController: UIViewController, authFlow: NetIdAuthFlow, forceApp2App: Bool = false) -> some View {
        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        // If there are no ID apps installed, but forceApp2App is true, return with an error.
        if netIdApps.isEmpty && forceApp2App {
            self.didFinishAuthenticationWithError(
                    NetIdError(code: .NoIdAppInstalled, process: .Authentication))
        }
        switch authFlow {
        case .Permission:
            return AnyView(AuthorizationSoftView(delegate: self, presentingViewController: currentViewController,
                    appIdentifiers: netIdApps))
        case .LoginPermission, .Login:
            return AnyView(AuthorizationHardView(delegate: self, presentingViewController: currentViewController,
                    appIdentifiers: netIdApps))
        }
//        case .Soft:
//            return AnyView(AuthorizationSoftView(delegate: self, presentingViewController: currentViewController,
//                    appIdentifiers: [AppIdentifier(id: 0, name: "GMX", backgroundColor: "#FF402FD2", foregroundColor: "#FFFFFFFF",
//                            icon: "logo_gmx", typeFaceIcon: "typeface_gmx", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test"),
//                            android: AppDetailsAndroid(applicationId: "test")),
//                        AppIdentifier(id: 1, name: "WEB,DE", backgroundColor: "#FFF7AD0A", foregroundColor: "#FFFFFFFF",
//                                icon: "logo_web_de", typeFaceIcon: "typeface_webde",
//                                iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test"),
//                                android: AppDetailsAndroid(applicationId: "test"))]))
//        case .Hard:
//            return AnyView(AuthorizationHardView(delegate: self, presentingViewController: currentViewController,
//                    appIdentifiers: [AppIdentifier(id: 0, name: "GMX", backgroundColor: "#FF402FD2", foregroundColor: "#FFFFFFFF",
//                            icon: "logo_gmx", typeFaceIcon: "typeface_gmx", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test"),
//                            android: AppDetailsAndroid(applicationId: "test")),
//                        AppIdentifier(id: 1, name: "WEB.DE", backgroundColor: "#FFF7AD0A", foregroundColor: "#FFFFFFFF",
//                                icon: "logo_web_de", typeFaceIcon: "typeface_webde",
//                                iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test"),
//                                android: AppDetailsAndroid(applicationId: "test"))]))
//        }
    }

    /**
     Provides the view controller
     - Parameter currentViewController:
     - Parameter authFlow:
     - Parameter forceApp2App: whether the app2app flow should be forced or not. If set to true and no ID apps are installed, this will yield an error of type NoIdAppInstalled. Defaults to false.
     - Returns:
     */
    public func getAuthorizationButtons(currentViewController: UIViewController, authFlow: NetIdAuthFlow, forceApp2App: Bool = false) -> some View {
        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        // If there are no ID apps installed, but forceApp2App is true, return with an error.
        if netIdApps.isEmpty && forceApp2App {
            self.didFinishAuthenticationWithError(
                    NetIdError(code: .NoIdAppInstalled, process: .Authentication))
        }

        switch authFlow {
        case .Permission:
            return AnyView(AuthorizationSoftView(delegate: self, presentingViewController: currentViewController,
                    appIdentifiers: netIdApps))
        case .Login, .LoginPermission:
            return AnyView(AuthorizationHardView(delegate: self, presentingViewController: currentViewController,
                    appIdentifiers: netIdApps))
        }
    }
    
    /**
     Actual call to start the authorization process. If ID apps are present, an app2app flow will be used. Otherwise, app2web is used.
     - Parameter destinationScheme: the scheme to set for calling another app for authorization
     - Parameter currentViewController: the view controller to use in case of app2web flow
     */
    public func authorize(destinationScheme: String?, currentViewController: UIViewController, authFlow: NetIdAuthFlow) {
        if handleConnection(.Authentication) {
            if let scheme = destinationScheme/*, let originScheme = netIdConfig?.originUrlScheme*/ {
                if !scheme.isEmpty {
                    Logger.shared.info("netID Service will authorize via App2App.")
                    if let url = appAuthManager?.getAuthRequestForUrl(url: URL(string: scheme)!, authFlow: authFlow) {
//                    if let url = AuthorizationWayUtil.createAuthorizeDeepLink(scheme, originScheme: originScheme) {
                        UIApplication.shared.open(url, completionHandler: { success in
                            if success {
                                Logger.shared.info("netID Service successfully opened: \(url)")
                            } else {
                                Logger.shared.error("netID Service could not open: \(url)")
                                // Todo: Remove this autofallback to app2web once app2app is working
                                Logger.shared.info("netID Service will authorize via web as a fallback.")
                                self.appAuthManager?.authorizeWeb(presentingViewController: currentViewController, authFlow: authFlow)
                            }
                        })
                    }
                }
            } else {
                Logger.shared.info("netID Service will authorize via web.")
                appAuthManager?.authorizeWeb(presentingViewController: currentViewController, authFlow: authFlow)
            }
        }
    }

    /**
     Function to end a session.
     */
    public func endSession() {
        Logger.shared.debug("netID Service will end session.")
        appAuthManager?.endSession()
    }

    /**
     Fetches the user info.
     */
    public func fetchUserInfo() {
        if handleConnection(.UserInfo) {
            Logger.shared.info("netID Service will fetch user info.")
            guard let accessToken = appAuthManager?.getAccessToken() else {
                for item in netIdListener {
                    Logger.shared.error("netID Service is unable to fetch user info caused by missing authentication.")
                    item.didFetchUserInfoWithError(NetIdError(code: .NoAuth, process: .PermissionRead))
                }
                return
            }
            guard let host = netIdConfig?.host else {
                for item in netIdListener {
                    Logger.shared.error("netID Service is unable to fetch user info caused by missing server host information.")
                    item.didFetchUserInfoWithError(NetIdError(code: .InitializationError, process: .PermissionRead))
                }
                return
            }
            userInfoManager?.fetchUserInfo(host: host, accessToken: accessToken)
        }
    }

    /**
     Fetch permissions.
     - Parameter collapseSyncId: boolean value to indicate if syncId is used or not.
     */
    public func fetchPermissions(collapseSyncId: Bool = true) {
        if handleConnection(.PermissionRead) {
            Logger.shared.info("netID Service will fetch permissions.")
            guard let accessToken = appAuthManager?.getPermissionToken() else {
                for item in netIdListener {
                    item.didFetchPermissionsWithError(NetIdError(code: .NoAuth, process: .PermissionRead))
                }
                return
            }
            permissionManager?.fetchPermissions(accessToken: accessToken, collapseSyncId: collapseSyncId)
        }
    }

    /**
     Update permissions.
     - Parameter permission: permissions to set of type ``NetIdPermissionUpdate``.
     - Parameter collapseSyncId: boolean value to indicate if syncId is used or not.
     */
    public func updatePermission(_ permission: NetIdPermissionUpdate, collapseSyncId: Bool = true) {
        if handleConnection(.PermissionRead) {
            Logger.shared.info("netID Service will update permission.")
            guard let accessToken = appAuthManager?.getPermissionToken() else {
                for item in netIdListener {
                    item.didUpdatePermissionWithError(NetIdError(code: .NoAuth, process: .PermissionWrite))
                }
                return
            }
            permissionManager?.updatePermission(accessToken: accessToken, permission: permission, collapseSyncId: collapseSyncId)
        }
    }

    /**
     Checks wheather there is a network connection or not.
     - Parameter process: process to signal in case of an error
     - Returns bool
     */
    private func handleConnection(_ process: NetIdErrorProcess) -> Bool {
        if Reachability.hasConnection() {
            Logger.shared.info("netID Service Device has network connection.")
            return true
        } else {
            Logger.shared.error("netID Service device has no network connection.")
            for item in netIdListener {
                item.didEncounterNetworkError(NetIdError(code: .NetworkError, process: process))
            }
            return false
        }
    }
}

extension NetIdService: AppAuthManagerDelegate {
    func didFinishInitializationWithError(_ error: NetIdError?) {
        for item in netIdListener {
            if let error = error {
                Logger.shared.error("netID Service initialization failed with error: " + error.code.rawValue)
                item.didFinishInitializationWithError(error)
            } else {
                Logger.shared.info("netID Service initialization finished")
                item.didFinishInitializationWithError(nil)
            }
        }
    }

    func didFinishAuthenticationWithError(_ error: NetIdError?) {
        for item in netIdListener {
            if let error = error {
                Logger.shared.error("netID Service authentication failed with error: " + error.code.rawValue)
                item.didFinishAuthenticationWithError(error)
            } else {
                if let accessToken = appAuthManager?.authState?.lastTokenResponse?.accessToken {
                    Logger.shared.info("netID Service received access token: " + accessToken)
                    item.didFinishAuthentication(accessToken)
                } else {
                    let error = NetIdError(code: .NoAuth, process: .Authentication)
                    Logger.shared.error("netID Service authentication failed with error: " + error.code.rawValue)
                    item.didFinishAuthenticationWithError(error)
                }
            }
        }
    }

    func didEndSession() {
        Logger.shared.info("netID Service did end session")
        for item in netIdListener {
            item.didEndSession()
        }
    }
}

extension NetIdService: UserInfoManagerDelegate {
    func didFetchUserInfo(_ userInfo: UserInfo) {
        Logger.shared.info("netID Service received user info")
        for item in netIdListener {
            item.didFetchUserInfo(userInfo)
        }
    }

    func didFetchUserInfoWithError(_ error: NetIdError) {
        Logger.shared.error("netID Service user info fetch failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didFetchUserInfoWithError(error)
        }
    }
}

extension NetIdService: PermissionManagerDelegate {
    public func didFetchPermissions(_ permissions: Permissions) {
        Logger.shared.info("netID Service received permissions.")
        for item in netIdListener {
            item.didFetchPermissions(permissions)
        }
    }

    public func didFetchPermissionsWithError(_ error: NetIdError) {
        Logger.shared.error("netID Service permissions fetch failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didFetchPermissionsWithError(error)
        }
    }

    public func didUpdatePermission(_ permission: SubjectIdentifiers) {
        Logger.shared.info("netID Service permission successfully updated. \(permission)")
        for item in netIdListener {
            item.didUpdatePermission()
        }
    }

    public func didUpdatePermissionWithError(_ error: NetIdError) {
        Logger.shared.error("netID Service permission update failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didUpdatePermissionWithError(error)
        }
    }
}

extension NetIdService: AuthorizationViewDelegate {
    public func didTapDismiss() {
        for item in netIdListener {
            item.didCancelAuthentication(NetIdError(code: .AuthorizationCanceledByUser, process: .Authentication))
        }
    }

    public func didTapContinue(destinationScheme: String?, presentingViewController: UIViewController, authFlow: NetIdAuthFlow) {
        authorize(destinationScheme: destinationScheme, currentViewController: presentingViewController, authFlow: authFlow)
    }
}
