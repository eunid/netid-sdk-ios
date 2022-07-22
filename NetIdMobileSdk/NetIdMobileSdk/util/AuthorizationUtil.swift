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

class AuthorizationWayUtil {
    struct Constants {
        static let netIdAppIdentifiers = "netIdAppIdentifiers"
        static let appIdentifiers = "appIdentifier"
        static let jsonFileType = "json"
    }

    static public func checkNetIdAuthWay() -> [String]? {
        if let path = Bundle.main.path(forResource: Constants.netIdAppIdentifiers, ofType: Constants.jsonFileType) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                   let appIdentifiers = jsonResult[Constants.appIdentifiers] as? [String] {
                    var availableNetIdApps: [String] = []
                    for item in appIdentifiers {
                        if isAppInstalled(item) {
                            Logger.shared.debug("App is installed: " + item)
                            availableNetIdApps.append(item)
                        }
                    }
                    return availableNetIdApps
                }
            } catch {
                Logger.shared.error("App identifier json parse error")
            }
        }
        return nil
    }

    static public func isAppInstalled(_ appName: String) -> Bool {
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)

        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            return true
        } else {
            return false
        }
    }
}