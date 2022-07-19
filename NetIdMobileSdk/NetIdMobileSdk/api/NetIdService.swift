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

class NetIdService: NSObject {

    static let sharedInstance = NetIdService()

    private var netIdConfig: NetIdConfig?
    private var netIdListener: [NetIdServiceDelegate] = []
    private var appAuthManager: AppAuthManager?

    public func registerListener(_ listener: NetIdServiceDelegate) {
        netIdListener.append(listener)
    }

    public func initialize(_ netIdConfig: NetIdConfig) {
        if self.netIdConfig != nil {
            Logger.shared.debug("Configuration already been set.")
        } else {
            self.netIdConfig = netIdConfig
            appAuthManager = AppAuthManager(delegate: self)
            appAuthManager?.fetchConfiguration(netIdConfig.host)
        }
    }

    public func getNedIdConfig() -> NetIdConfig? {
        netIdConfig
    }

    public func checkForNetIdAuthPossibility(currentViewController: UIViewController) -> UIViewController {
        if let netIdApps = AuthorizationWayUtil.checkNetIdAuthWay() {
            if netIdApps.count > 0 {
                //TODO return view controller with multiple app login
                for item in netIdApps {

                }
            } else {
                //TODO return view controller with web login
            }
        } else {
            //TODO return view controller with web login
        }
    }

    public func authorize(bundleIdentifier: String?, currentViewController: UIViewController) {
        if let bundleIdent = bundleIdentifier?.isEmpty {
            //TODO jump into app2app flow (deeplink?)
        } else {
            appAuthManager?.authorizeWeb(presentingViewController: currentViewController)
        }
    }
}

extension NetIdService: AppAuthManagerDelegate {
    func didReceiveConfig() {

    }

    func didReceiveToken() {
        if let accessToken = appAuthManager?.authState?.lastTokenResponse?.accessToken {
            Logger.shared.debug("Received access token in NetIdService" + accessToken)
        }
    }

    func didReceiveError(process: NetIdErrorProcess) {

    }
}
