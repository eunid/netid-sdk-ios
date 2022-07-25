//
//  ShippingAddress.swift
//  NetIdMobileSdk
//
//  Created by Felix Hug on 25.07.22.
//

import Foundation

struct ShippingAddress: Decodable {
    let streetAddress: String
    let country: String
    let formatted: String
    let locality: String
    let postalCode: String
    let recipient: String

    private enum CodingKeys: String, CodingKey {
        case streetAddress = "street_address", country, formatted, locality, postalCode = "postal_code",
             recipient
    }
}
