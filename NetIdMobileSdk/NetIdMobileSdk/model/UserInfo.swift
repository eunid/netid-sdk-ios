//
//  UserInfo.swift
//  NetIdMobileSdk
//
//  Created by Felix Hug on 25.07.22.
//

import Foundation

struct UserInfo: Decodable {
    let sub: String
    let birthdate: String
    let emailVerified: Bool
    let address: Address
    let gender: String
    let shippingAddress: ShippingAddress
    let givenName: String
    let familyName: String
    let email: String

    private enum CodingKeys: String, CodingKey {
        case sub, birthdate, emailVerified = "email_verified", address, gender,
             shippingAddress = "shipping_address", givenName = "given_name", familyName = "family_name", email
    }
}
