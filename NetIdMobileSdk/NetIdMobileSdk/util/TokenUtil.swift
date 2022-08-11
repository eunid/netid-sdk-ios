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

public class TokenUtil {
    private struct Constants {
        static let accessTokenKey = "access_token"
        static let permissionManagementKey = "permission_management"
    }

    class func decode(token: String) -> Data? {
        let segments = token.components(separatedBy: ".")
        var base64 = segments[1]
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    class func getPermissionTokenFrom(_ token: String) -> String? {
        guard let data = decode(token: token) else {
            return nil
        }
        guard let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        let permissionClaim = jsonData[Constants.permissionManagementKey] as? [String: Any]
        return permissionClaim?[Constants.accessTokenKey] as? String
    }
}