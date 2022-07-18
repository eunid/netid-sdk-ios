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

import UIKit
import Foundation

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

    public func authorize() {}

    public func checkNetIdPossibility() {
        let asset = NSDataAsset(name: "netIdAppIdentifiers", bundle: Bundle.main)
        let json = try? JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments)
        if let appIdentifiers = json["appIdentifiers"] as? [String] {
            for item in appIdentifiers {
                if isAppInstalled(item) {
                    Logger.shared.debug("App is installed: " + item)
                }
            }
        }
    }

    private func isAppInstalled(_ appName: String) -> Bool {
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)

        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            return true
        } else {
            return false
        }

    }
}

extension NetIdService: AppAuthManagerDelegate {
    func didReceiveConfig() {

    }

    func didReceiveError() {

    }
}
