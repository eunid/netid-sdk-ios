//
// Created by Felix Hug on 19.07.22.
//

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