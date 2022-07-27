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
        static let netIdAuthorizePath = "://netid_authorize"
        static let jsonFileType = "json"
    }

    class func checkNetIdAuth() -> [AppIdentifier]? {
        if let path = Bundle(for: self).path(forResource: Constants.netIdAppIdentifiers, ofType: Constants.jsonFileType) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let appIdentifiers: NetIdAppIdentifiers = try JSONDecoder().decode(NetIdAppIdentifiers.self, from: data)
                var installedAppIdentifiers = [AppIdentifier]()
                for item in appIdentifiers.netIdAppIdentifiers {
                    if isAppInstalled(item.iOS.scheme) {
                        installedAppIdentifiers.append(item)
                    }
                }
                return installedAppIdentifiers
            } catch {
                Logger.shared.error("App identifier json parse error")
            }
        }
        return nil
    }

    class func isAppInstalled(_ urlScheme: String) -> Bool {
        let appScheme = "\(urlScheme)://app"
        let appUrl = URL(string: appScheme)

        if UIApplication.shared.canOpenURL(appUrl! as URL) {
            return true
        } else {
            return false
        }
    }

    class func createAuthorizeDeepLink(_ scheme: String) -> URL? {
        URL(string: scheme + Constants.netIdAuthorizePath)
    }
}
