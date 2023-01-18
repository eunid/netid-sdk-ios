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

public struct PermissionUpdateResponse: Decodable, Encodable, CustomStringConvertible {
    public let subjectIdentifiers: SubjectIdentifiers

    public init(subjectIdentifiers: SubjectIdentifiers) {
        self.subjectIdentifiers = subjectIdentifiers
    }

    private enum CodingKeys: String, CodingKey {
        case subjectIdentifiers = "subject_identifiers"
    }
    
    public var description: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(subjectIdentifiers, forKey: .subjectIdentifiers)
    }
}
