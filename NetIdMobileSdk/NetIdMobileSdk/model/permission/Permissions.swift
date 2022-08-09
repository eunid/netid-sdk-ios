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

public struct Permissions: Decodable, CustomStringConvertible {
    public let statusCode: PermissionStatusCode
    public let subjectIdentifiers: SubjectIdentifiers
    public let netIdPrivacySettings: [NetIdPrivacySettings]

    public init(statusCode: PermissionStatusCode, subjectIdentifiers: SubjectIdentifiers, netIdPrivacySettings: [NetIdPrivacySettings]) {
        self.statusCode = statusCode
        self.subjectIdentifiers = subjectIdentifiers
        self.netIdPrivacySettings = netIdPrivacySettings
    }

    public var description: String {
        "Permissions(statusCode: \(statusCode), subjectIdentifiers: \(subjectIdentifiers), netIdPrivacySettings: \(netIdPrivacySettings))"
    }

    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code", subjectIdentifiers = "subject_identifiers", netIdPrivacySettings = "netid_privacy_settings"
    }
}
