//
// Created by Felix Hug on 19.07.22.
//

import Foundation
import UIKit

class AuthorizationWayUtil {
    struct Constants {
        static let netIdAppIdentifiers = "netIdAppIdentifiers"
        static let jsonFileType = "json"
    }

    static public func checkNetIdAuth() -> [AppIdentifier]? {
        if let path = Bundle.main.path(forResource: Constants.netIdAppIdentifiers, ofType: Constants.jsonFileType) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let appIdentifiers: NetIdAppIdentifiers = try! JSONDecoder().decode(NetIdAppIdentifiers.self, from: data)
                return appIdentifiers.netIdAppIdentifiers
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
