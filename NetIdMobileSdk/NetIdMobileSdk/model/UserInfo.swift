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

public struct UserInfo: Decodable, Encodable, CustomStringConvertible {

    public init(sub: String, birthdate: String, emailVerified: Bool, address: Address, gender: String, shippingAddress: ShippingAddress,
                givenName: String, familyName: String, email: String) {
        self.sub = sub
        self.birthdate = birthdate
        self.emailVerified = emailVerified
        self.address = address
        self.gender = gender
        self.shippingAddress = shippingAddress
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
    
    public let sub: String
    public let birthdate: Optional<String>
    public let emailVerified: Optional<Bool>
    public let address: Optional<Address>
    public let gender: Optional<String>
    public let shippingAddress: Optional<ShippingAddress>
    public let givenName: Optional<String>
    public let familyName: Optional<String>
    public let email: Optional<String>
    
    private enum CodingKeys: String, CodingKey {
        case sub, birthdate, emailVerified = "email_verified", address, gender,
             shippingAddress = "shipping_address", givenName = "given_name", familyName = "family_name", email
    }

    public var description: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(sub, forKey: .sub)
        try container.encodeIfPresent(birthdate, forKey: .birthdate)
        try container.encodeIfPresent(emailVerified, forKey: .emailVerified)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(shippingAddress, forKey: .shippingAddress)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(email, forKey: .email)

    }
}
