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

public struct Address: Decodable, Encodable {

    public init(streetAddress: String, country: String, formatted: String, locality: String, postalCode: String) {
        self.streetAddress = streetAddress
        self.country = country
        self.formatted = formatted
        self.locality = locality
        self.postalCode = postalCode
    }

    public let streetAddress: String
    public let country: String
    public let formatted: String
    public let locality: String
    public let postalCode: String

    private enum CodingKeys: String, CodingKey {
        case streetAddress = "street_address", country, formatted, locality, postalCode = "postal_code"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(streetAddress, forKey: .streetAddress)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(formatted, forKey: .formatted)
        try container.encodeIfPresent(locality, forKey: .locality)
        try container.encodeIfPresent(postalCode, forKey: .postalCode)
    }
}
