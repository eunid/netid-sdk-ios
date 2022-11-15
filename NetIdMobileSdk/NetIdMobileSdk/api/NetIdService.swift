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

/**
 The ``NetIdService`` is the main class of the sdk.
 
 An application communicates via this class with the authorization service.
 
 To do so, an application first registers itself as a listener to the service.

 ```NetIdService.sharedInstance.registerListener(self)```
   
 Next, initialize the service with a configuration object of kind ``NetIdConfig``.
 
 The application has to conform to the ``NetIdServiceDelegate`` protocol and implement the required functions (see below).

 
 ```NetIdService.sharedInstance.initialize(config)```
 */
open class NetIdService: NSObject {

    public static let sharedInstance = NetIdService()
    private var netIdConfig: NetIdConfig?
    private var netIdListener: [NetIdServiceDelegate] = []
    private var appAuthManager: AppAuthManager?
    private var userInfoManager: UserInfoManager?
    private var permissionManager: PermissionManager?
    private var selectedAppIndex = 0
    private let broker = "broker.netid.de"

    /**
      Registers a new listener of type NetIdServiceDelegate
     - Parameter listener: the new listener
     */
    public func registerListener(_ listener: NetIdServiceDelegate) {
        netIdListener.append(listener)
    }

    /**
     Initializes the sdk and loads the authentication configuration document.
     - Parameter netIdConfig: the client configuration of type ``NetIdConfig``.
     */
    public func initialize(_ netIdConfig: NetIdConfig) {
        if handleConnection(.Configuration) {
            if self.netIdConfig != nil {
                Logger.shared.debug("Configuration already been set.")
            } else {
                self.netIdConfig = netIdConfig
                userInfoManager = UserInfoManager(delegate: self)
                permissionManager = PermissionManager(delegate: self)
                appAuthManager = AppAuthManager(delegate: self, netIdConfig: netIdConfig)
                appAuthManager?.fetchConfiguration(broker)
            }
        }
    }

    /**
     Provides the currently stored ``NetIdConfig``.
     - Returns: Current ``NetIdConfig``
     */
    public func getNetIdConfig() -> NetIdConfig? {
        netIdConfig
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
     Returns an authorization view, that conforms to the desired ``NetIdAuthFlow``. The view will consist off all buttons, logos and texts that arre neccessary to start the authentication process.
     - Parameter currentViewController: Currently used view controller.
     - Parameter authFlow: Type of flow to use, can be either ``NetIdAuthFlow.Permission``, ``NetIdAuthFlow.Login`` or ``NetIdAuthFlow.LoginPermission``
     - Parameter forceApp2App: If set to true, will yield an ``NetIdError`` if the are no ID apps installed. Otherwise, will use app2web flow automatically. Defaults to ``false``.
     - Returns: view
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
            let config = netIdConfig?.permissionLayerConfig
            return AnyView(AuthorizationPermissionView(delegate: self, presentingViewController: currentViewController,
                                                 appIdentifiers: netIdApps, logoId: (config?.logoId) ?? "", headlineText: (config?.headlineText) ?? "", legalText: (config?.legalText) ?? "", continueText: (config?.continueText) ?? ""))
        case .LoginPermission, .Login:
            let config = netIdConfig?.loginLayerConfig
            return AnyView(AuthorizationLoginView(delegate: self, presentingViewController: currentViewController,
                                                  appIdentifiers: netIdApps, authFlow: authFlow, headlineText: (config?.headlineText) ?? "", loginText: (config?.loginText) ?? "", continueText: (config?.continueText) ?? ""))
        }
    }
    
    /**
     Returns the continue button in case of a permission flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter currentViewController: Currently used view controller.
     - Parameter continueText: alternative text to set on the button. If empty, the default will be used.
     - Returns: Continue button
     */
    @ViewBuilder
    public func continueButtonPermissionFlow(presentingViewController: UIViewController, continueText: String, colorScheme: ColorScheme) -> some View {
        let bundle = Bundle(for: NetIdService.self)

        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        Button {
            var destinationScheme: String?
            if netIdApps.count > self.selectedAppIndex {
                let selectedAppIdentifier = netIdApps[self.selectedAppIndex]
                destinationScheme = selectedAppIdentifier.iOS.universalLink
            }
            self.didTapContinue(destinationScheme: destinationScheme, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Permission)
        } label: {
            ZStack {
                Image("logo_net_id_short", bundle: bundle)
                    .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id") : continueText)
                    .kerning(-0.45)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("netIdButtonColor", bundle: bundle))
                    .font(Font.system(size: 18, weight: .semibold))
            }
            .padding(12)
            .background(Color("netIdOtherOptionsColor", bundle: bundle))
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(colorScheme == .dark ? "netIdLayerColor" : "closeButtonGrayColor", bundle: bundle)))
        }
    }

    /**
     Returns the continue button in case of a login flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter currentViewController: Currently used view controller.
     - Parameter continueText: alternative text to set on the button. If empty, the default will be used.
     - Returns: Continue button
     */
    @ViewBuilder
    public func continueButtonLoginFlow(presentingViewController: UIViewController, continueText: String, colorScheme: ColorScheme) -> some View {
        let bundle = Bundle(for: NetIdService.self)

        Button {
            self.didTapContinue(destinationScheme: nil, presentingViewController: presentingViewController, authFlow: .Login)
        } label: {
            ZStack {
                Image("logo_net_id_short", bundle: bundle)
                    .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_title") : continueText)
                    .kerning(-0.45)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("authorizationTitleColor", bundle: bundle))
                    .font(Font.system(size: 18, weight: .semibold))
            }
        }
        .padding(12)
        .background(Color("netIdOtherOptionsColor", bundle: bundle))
        .cornerRadius(5)
        .padding(.horizontal, 20)
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(colorScheme == .dark ? "netIdLayerColor" : "closeButtonGrayColor", bundle: bundle)).padding(.horizontal, 20))
    }
    
    /**
     Returns the number of installed id apps.
     Use this function only if you intent to build your very own authorization dialog.
     - Returns: Number of currently installed id apps.
     */
    public func getCountOfIdApps() -> Int {
        return AuthorizationWayUtil.checkNetIdAuth().count
    }
    
    /**
     Returns the radio button for a certain id app in case of a permission flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter index: Index denoting one of the installed id apps. Use ``getCountOfIdApps`` first to get the number of installed id apps.
     - Returns: Button with text and label for the choosen id app. If index is out of bounds or no app is installed, returns an empty view.
     */
    @ViewBuilder
    public func permissionButtonForIdApp(index: Int) -> some View {
        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        if ((netIdApps.isEmpty) || (index >= netIdApps.count)) {
            EmptyView()
        }
        let result = netIdApps[index]
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: result.backgroundColor) ?? Color.white)
                    .frame(width: 40, height: 40)

                Image(result.icon, bundle: Bundle(for: NetIdService.self))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28, alignment: .center)
            }
            Text(String(format: LocalizableUtil.netIdLocalizable("authorization_view_use_app"), result.name))
                .kerning(-0.45)
                .font(Font.system(size: 16, weight: .bold))

            Spacer()

            let radioCheckedBinding = Binding<Bool>(get: { self.selectedAppIndex == index }, set: { _ in })

            RadioButtonView(isChecked: radioCheckedBinding, didSelect: {
                self.selectedAppIndex = index
            })
        }
                .tag(result.name)
                .padding(.vertical, 10)
                .background(Color("netIdLayerColor", bundle: Bundle(for: NetIdService.self)))
                .onTapGesture {
                    self.selectedAppIndex = index
                }
    }
    
    /**
     Returns the button for a certain id app in case of a login flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter presentingViewController: view controller to hook up button to.
     - Parameter authFlow: Must either be .Login or .LoginPermission. If is set to .Permission, an empty viel will be returned.
     - Parameter index: Index denoting one of the installed id apps. Use ``getCountOfIdApps`` first to get the number of installed id apps.
     - Returns: Button with text and label for the choosen id app. If index is out of bounds or no app is installed, returns an empty view.
     */
    @ViewBuilder
    public func loginButtonForIdApp(presentingViewController: UIViewController, authFlow: NetIdAuthFlow, index: Int, loginText: String = "") -> some View {
        let bundle = Bundle(for: NetIdService.self)

        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        if ((netIdApps.isEmpty) || (index >= netIdApps.count)) {
            EmptyView()
        }
        let result = netIdApps[index]
        
        if (authFlow == .Permission) {
            EmptyView()
        }
        
        Button {
            self.didTapContinue(destinationScheme: result.iOS.universalLink, presentingViewController: presentingViewController, authFlow: authFlow)
        } label: {
            ZStack {
                Image(result.icon, bundle: bundle)
                    .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                Text(String(format: loginText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_continue_with") : loginText, result.name))
                    .kerning(-0.45)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(hex: result.foregroundColor))
                    .font(Font.system(size: 18, weight: .semibold))
            }
        }
            .tag(result.name)
            .padding(12)
            .background(Color(hex: result.backgroundColor))
            .cornerRadius(5)
            .padding(.horizontal, 20)
    }
    
    /**
     Actual call to start the authorization process. If ID apps are present, an app2app flow will be used. Otherwise, app2web is used.
     - Parameter destinationScheme: the scheme to set for calling another app for authorization
     - Parameter currentViewController: the view controller to use in case of app2web flow
     */
    public func authorize(destinationScheme: String?, currentViewController: UIViewController, authFlow: NetIdAuthFlow) {
        if handleConnection(.Authentication) {
            if let scheme = destinationScheme {
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
     The net ID service itself still remains initialzed but all information about authorization/authentication is discarded.
     To start a new session, call ``authorize(destinationScheme:currentViewController:authFlow)`` again.
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
            guard let userinfoEndpoint = appAuthManager?.authConfiguration?.discoveryDocument?.userinfoEndpoint else {
                for item in netIdListener {
                    Logger.shared.error("netID Service is unable to fetch userinfo endpoint caused by missing discovery document.")
                    item.didFetchUserInfoWithError(NetIdError(code: .InvalidDiscoveryDocument, process: .UserInfo))
                }
                return
            }
            userInfoManager?.fetchUserInfo(userinfoEndpoint: userinfoEndpoint, accessToken: accessToken)
        }
    }

    /**
     Fetch permissions.
     - Parameter collapseSyncId: boolean value to indicate whether syncId is used or not.
     */
    public func fetchPermissions(collapseSyncId: Bool = true) {
        if handleConnection(.PermissionRead) {
            Logger.shared.info("netID Service will fetch permissions.")
            guard let accessToken = appAuthManager?.getPermissionToken() else {
                for item in netIdListener {
                    item.didFetchPermissionsWithError(NetIdError(code: .NoAuth, process: .PermissionRead), originalError: nil)
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
                    item.didUpdatePermissionWithError(NetIdError(code: .NoAuth, process: .PermissionWrite), originalError: nil)
                }
                return
            }
            permissionManager?.updatePermission(accessToken: accessToken, permission: permission, collapseSyncId: collapseSyncId)
        }
    }

    /**
     Checks wheather there is a network connection or not.
     - Parameter process: In case of an error, denotes the process that the error is responsible for.
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

    public func didFetchPermissionsWithError(_ error: NetIdError, originalError: Error?) {
        Logger.shared.error("netID Service permissions fetch failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didFetchPermissionsWithError(error, originalError: originalError)
        }
    }

    public func didUpdatePermission(_ permission: SubjectIdentifiers) {
        Logger.shared.info("netID Service permission successfully updated. \(permission)")
        for item in netIdListener {
            item.didUpdatePermission()
        }
    }

    public func didUpdatePermissionWithError(_ error: NetIdError, originalError: Error?) {
        Logger.shared.error("netID Service permission update failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didUpdatePermissionWithError(error, originalError: originalError)
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
