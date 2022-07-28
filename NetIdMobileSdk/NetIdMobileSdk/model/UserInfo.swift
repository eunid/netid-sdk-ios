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

public struct UserInfo: Decodable, CustomStringConvertible {
    public init(sub: String, birthdate: String, givenName: String, familyName: String) {
        self.sub = sub
        self.birthdate = birthdate
        self.givenName = givenName
        self.familyName = familyName
    }

//    public init(sub: String, birthdate: String, emailVerified: Bool, address: Address, gender: String, shippingAddress: ShippingAddress,
//                givenName: String, familyName: String, email: String) {
//        self.sub = sub
//        self.birthdate = birthdate
//        self.emailVerified = emailVerified
//        self.address = address
//        self.gender = gender
//        self.shippingAddress = shippingAddress
//        self.givenName = givenName
//        self.familyName = familyName
//        self.email = email
//    }

    public let sub: String
    public let birthdate: String
//    public let emailVerified: Bool
//    public let address: Address
//    public let gender: String
//    public let shippingAddress: ShippingAddress
    public let givenName: String
    public let familyName: String

//    public let email: String

    private enum CodingKeys: String, CodingKey {
        case sub, birthdate, givenName = "given_name", familyName = "family_name"
    }

    public var description: String {
        "UserInfo(sub: \(sub), birthdate: \(birthdate), givenName: \(givenName), familyName: \(familyName))"
    }
//    private enum CodingKeys: String, CodingKey {
//        case sub, birthdate, emailVerified = "email_verified", address, gender,
//             shippingAddress = "shipping_address", givenName = "given_name", familyName = "family_name", email
//    }
}
