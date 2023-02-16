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

public struct SubjectIdentifiers: Decodable, Encodable, CustomStringConvertible {
    public let tpId: String?
    public let syncId: String?

    public init(tpId: String, syncId: String) {
        self.tpId = tpId
        self.syncId = syncId
    }

    private enum CodingKeys: String, CodingKey {
        case tpId = "tpid", syncId = "sync_id"
    }
    
    public var description: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(tpId, forKey: .tpId)
        try container.encodeIfPresent(syncId, forKey: .syncId)
    }
}
