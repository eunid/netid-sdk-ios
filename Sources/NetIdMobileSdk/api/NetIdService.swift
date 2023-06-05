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
    private var layerStyle: NetIdLayerStyle = .Solid
    private var buttonStyle: NetIdButtonStyle = .WhiteSolid
    private var netIdLogoResource: String = "logo_net_id_short"
    private var buttonBackgroundResource:String = "netIdOtherOptionsColor"
    private var buttonForegroundResource:String = "netIdButtonColor"
    private var buttonOutlineResource:String = "netIdButtonColor"

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
        // Try to resume session with provided url
        if let authManager = appAuthManager, let authorizationFlow = authManager.currentAuthorizationFlow {
            if (authorizationFlow.resumeExternalUserAgentFlow(with: url)) {
                // end session after sucessfull processing
                authManager.currentAuthorizationFlow = nil
            }
        }
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
                                                 appIdentifiers: netIdApps, logoName: (config?.logoName) ?? "", headlineText: (config?.headlineText) ?? "", legalText: (config?.legalText) ?? "", continueText: (config?.continueText) ?? ""))
        case .LoginPermission, .Login:
            let config = netIdConfig?.loginLayerConfig
            return AnyView(AuthorizationLoginView(delegate: self, presentingViewController: currentViewController,
                                                  appIdentifiers: netIdApps, authFlow: authFlow, headlineText: (config?.headlineText) ?? "", loginText: (config?.loginText) ?? "", continueText: (config?.continueText) ?? ""))
        }
    }
    
    /**
     Sets the style to use for all layers when using the layer flow.
     - Parameter layerStyle: button style to set, can be any of ``NetIdLayerStyle``, defaults to ``NetIdLayerStyle.Solid``
     */
    public func setLayerStyle(_ layerStyle: NetIdLayerStyle) {
        self.layerStyle = layerStyle

        switch layerStyle {
            case .Outline:
                self.netIdLogoResource = "logo_net_id_short"
                self.buttonBackgroundResource = "netIdTransparentColor"
                self.buttonForegroundResource = "netIdButtonColor"
                self.buttonOutlineResource = "netIdButtonOutlineColor"
            default:
                self.netIdLogoResource = "logo_net_id_short"
                self.buttonBackgroundResource = "netIdOtherOptionsColor"
                self.buttonForegroundResource = "netIdButtonColor"
                self.buttonOutlineResource = "netIdButtonStrokeColor"
        }
    }
    
    /**
     Returns the currently set layer style.
     - Returns Currently set style.
     */
    public func getLayerStyle() -> NetIdLayerStyle {
        return layerStyle
    }

    /**
     Sets the style to use for all buttons when using the button flow.
     - Parameter buttonStyle: button style to set, can be any of ``NetIdButtonStyle``, defaults to ``NetIdButtonStyle.GraySolid``
     */
    public func setButtonStyle(_ buttonStyle: NetIdButtonStyle) {
        self.buttonStyle = buttonStyle
        
        switch buttonStyle {
            case .GreenSolid:
                self.netIdLogoResource = "logo_net_id_short_white"
                self.buttonBackgroundResource = "netIdGreenColor"
                self.buttonForegroundResource = "netIdWhiteColor"
                self.buttonOutlineResource = "netIdGreenColor"
            case .GrayOutline:
                self.netIdLogoResource = "logo_net_id_short"
                self.buttonBackgroundResource = "netIdTransparentColor"
                self.buttonForegroundResource = "netIdButtonColor"
                self.buttonOutlineResource = "netIdButtonOutlineColor"
            default:
                self.netIdLogoResource = "logo_net_id_short"
                self.buttonBackgroundResource = "netIdOtherOptionsColor"
                self.buttonForegroundResource = "netIdButtonColor"
                self.buttonOutlineResource = "netIdButtonStrokeColor"
        }
    }

    /**
     Returns the continue button in case of a permission flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter continueText: alternative text to set on the button. If empty, the default will be used.
     - Returns: Continue button
     */
    @ViewBuilder
    public func continueButtonPermissionFlow(continueText: String = "") -> some View {
        let bundle = Bundle.module
        
        let vc = UIApplication.shared.visibleViewController
        Button {
            self.didTapContinue(universalLink: nil, presentingViewController: vc ?? UIViewController(), authFlow: NetIdAuthFlow.Permission)
        } label: {
            ZStack {
                Image(netIdLogoResource, bundle: bundle)
                    .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id") : continueText)
                    .kerning(-0.45)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(buttonForegroundResource, bundle: bundle))
                    .font(Font.system(size: 18, weight: .semibold))
            }
            .padding(12)
            .background(Color(buttonBackgroundResource, bundle: bundle))
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(buttonOutlineResource, bundle: bundle)))
        }
    }

    /**
     Returns the continue button in case of a login flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter authFlow: Must either be .Login or .LoginPermission. If is set to .Permission, an empty view will be returned.
     - Parameter continueText: alternative text to set on the button. If empty, the default will be used.
     - Returns: Continue button
     */
    @ViewBuilder
    public func continueButtonLoginFlow(authFlow: NetIdAuthFlow, continueText: String = "") -> some View {
        let bundle = Bundle.module

        let vc = UIApplication.shared.visibleViewController

        if (authFlow == .Permission) {
            EmptyView()
        } else {
            Button {
                self.didTapContinue(universalLink: nil, presentingViewController: vc ?? UIViewController(), authFlow: authFlow)
            } label: {
                ZStack {
                    Image(netIdLogoResource, bundle: bundle)
                        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                    Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_title") : continueText)
                        .kerning(-0.45)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(buttonForegroundResource, bundle: bundle))
                        .font(Font.system(size: 18, weight: .semibold))
                }
                .padding(12)
                .background(Color(buttonBackgroundResource, bundle: bundle))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(buttonOutlineResource, bundle: bundle)))
            }
        }
    }
    
    /**
     Returns the number of installed account provider apps.
     Use this function only if you intent to build your very own authorization dialog.
     - Returns: Number of currently installed account provider apps.
     */
    public func getCountOfAccountProviderApps() -> Int {
        return AuthorizationWayUtil.checkNetIdAuth().count
    }
    
    /**
     Returns the keys of installed account provider apps. With these keys, you can request buttons for specific account provider apps identified by their key aka name.
     Use this function only if you intent to build your very own authorization dialog.
     - Returns: Array of keys of installed account provider apps.
     */
    public func getKeysForAccountProviderApps() -> [String] {
        var result:[String] = []
        let apps = AuthorizationWayUtil.checkNetIdAuth()
        for app in apps {
            result.append(app.name)
        }
        return result
    }
    
    /**
     Returns the button for a certain account provider app in case of a permission flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter key: Key denoting one of the installed account provider apps. Use ``getKeysForAccountProviderApps`` first to get the keys/names of all installed account provider apps.
     - Parameter continueText: alternative text to set on the button. If empty, the default will be used.
     - Returns: Button with text and label for the choosen id app. If index is out of bounds or no app is installed, returns an empty view.
     */
    @ViewBuilder
    public func permissionButtonForAccountProviderApp(key: String, continueText: String = "") -> some View {
        let bundle = Bundle.module
        
        let vc = UIApplication.shared.visibleViewController

        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        let keys = getKeysForAccountProviderApps()
        let index = keys.firstIndex(of: key) ?? -1
        if ((netIdApps.isEmpty) || (index < 0)) {
            EmptyView()
        } else {
            let result = netIdApps[index]
            
            Button {
                self.didTapContinue(universalLink: result.iOS.universalLink, presentingViewController: vc ?? UIViewController(), authFlow: .Permission)
            } label: {
                ZStack {
                    Image(netIdLogoResource, bundle: bundle)
                        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                    Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id") : continueText)                        .kerning(-0.45)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(buttonForegroundResource, bundle: bundle))
                        .font(Font.system(size: 18, weight: .semibold))
                }
                .padding(12)
                .background(Color(buttonBackgroundResource, bundle: bundle))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(buttonOutlineResource, bundle: bundle)))
            }
        }
    }
    
    /**
     Returns the button for a certain account provider app in case of a login flow dialog.
     Use this function only if you intent to build your very own authorization dialog.
     - Parameter authFlow: Must either be .Login or .LoginPermission. If is set to .Permission, an empty viel will be returned.
     - Parameter key: Key denoting one of the installed account provider apps. Use ``getKeysForAccountProviderApps`` first to get the keys/names of all installed account provider apps.
     - Returns: Button with text and label for the choosen id app. If index is out of bounds or no app is installed, returns an empty view.
     */
    @ViewBuilder
    public func loginButtonForAccountProviderApp(authFlow: NetIdAuthFlow, key: String) -> some View {
        let bundle = Bundle.module
        
        let vc = UIApplication.shared.visibleViewController

        let netIdApps = AuthorizationWayUtil.checkNetIdAuth()
        let keys = getKeysForAccountProviderApps()
        let index = keys.firstIndex(of: key) ?? -1
        if ((netIdApps.isEmpty) || (index < 0)) {
            EmptyView()
        } else {
            let result = netIdApps[index]
            
            if (authFlow == .Permission) {
                EmptyView()
            } else {
                
                Button {
                    self.didTapContinue(universalLink: result.iOS.universalLink, presentingViewController: vc ?? UIViewController(), authFlow: authFlow)
                } label: {
                    ZStack {
                        Image(netIdLogoResource, bundle: bundle)
                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                        Text(String(format: LocalizableUtil.netIdLocalizable("authorization_login_ap"), result.name))
                            .kerning(-0.45)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(buttonForegroundResource, bundle: bundle))
                            .font(Font.system(size: 18, weight: .semibold))
                    }
                    .padding(12)
                    .background(Color(buttonBackgroundResource, bundle: bundle))
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(buttonOutlineResource, bundle: bundle)))
                }
            }
        }
    }
    
    /**
     Actual call to start the authorization process. If ID apps are present, an app2app flow will be used. Otherwise, app2web is used.
     - Parameter destinationScheme: the scheme to set for calling another app for authorization
     - Parameter currentViewController: the view controller to use in case of app2web flow
     */
    public func authorize(universalLink: String?, currentViewController: UIViewController, authFlow: NetIdAuthFlow) {
        if handleConnection(.Authentication) {
            if let universalLink = universalLink,
            let universalLinkUrl = URL(string: universalLink) {
                Logger.shared.info("netID Service will authorize via app2app.")
                appAuthManager?.authorizeApp(universalLink: universalLinkUrl, authFlow: authFlow)
            } else {
                Logger.shared.info("netID Service will authorize via app2web.")
                appAuthManager?.authorizeWeb(presentingViewController: currentViewController, authFlow: authFlow)
            }
        }
    }

    /**
     Function to end a session.
     The net ID service itself still remains initialized but all information about authorization/authentication is discarded.
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
                    item.didFetchPermissionsWithError(.UNKNOWN, NetIdError(code: .UnauthorizedClient, process: .PermissionRead))
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
                    item.didUpdatePermissionWithError(.UNKNOWN, NetIdError(code: .UnauthorizedClient, process: .PermissionWrite))
                }
                return
            }
            permissionManager?.updatePermission(accessToken: accessToken, permission: permission, collapseSyncId: collapseSyncId)
        }
    }

    /**
     Checks whether there is a network connection or not.
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
                if (appAuthManager?.getAuthState() != nil) {
                    didFinishAuthenticationWithError(nil)
                }
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
    public func didFetchPermissions(_ permissions: PermissionReadResponse) {
        Logger.shared.info("netID Service received permissions.")
        for item in netIdListener {
            item.didFetchPermissions(permissions)
        }
    }

    public func didFetchPermissionsWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError) {
        Logger.shared.error("netID Service permissions fetch failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didFetchPermissionsWithError(permissionResponseStatus, error)
        }
    }

    public func didUpdatePermission(_ subjectIdentifiers: SubjectIdentifiers) {
        Logger.shared.info("netID Service permission successfully updated. \(subjectIdentifiers)")
        for item in netIdListener {
            item.didUpdatePermission(subjectIdentifiers)
        }
    }

    public func didUpdatePermissionWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError) {
        Logger.shared.error("netID Service permission update failed with error: " + error.code.rawValue)
        for item in netIdListener {
            item.didUpdatePermissionWithError(permissionResponseStatus, error)
        }
    }
}

extension NetIdService: AuthorizationViewDelegate {
    public func didTapDismiss() {
        for item in netIdListener {
            item.didCancelAuthentication(NetIdError(code: .AuthorizationCanceledByUser, process: .Authentication))
        }
    }

    public func didTapContinue(universalLink: String?, presentingViewController: UIViewController, authFlow: NetIdAuthFlow) {
        authorize(universalLink: universalLink, currentViewController: presentingViewController, authFlow: authFlow)
    }
}

#if !USES_SWIFT_PACKAGE_MANAGER

extension Bundle {
       
    // Make sure that we do return the correct bundle (if used as a library via Cocopods).
    static let module: Bundle = {
        
        /// Returns the `Bundle` instance that holds the resources for NetIdService
        let frameworkBundle = Bundle(for: NetIdService.self)
        // When using CocoaPods, resources are moved into a separate resource bundle "NetIdMobileSdk", load that
        let resourceBundleURL = frameworkBundle.url(forResource: "NetIdMobileSdk", withExtension: "bundle")
        // fails in case not used via Cocopods
        if (resourceBundleURL != nil) {
            return Bundle(url: resourceBundleURL!)!
        }
        // Alternatively just return the framework bundle itself (xcode build and not SPM)
        return frameworkBundle
    }()
}

#endif
