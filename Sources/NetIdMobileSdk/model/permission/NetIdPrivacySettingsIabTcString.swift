//
//  NetIdPrivacySettingsIabTcString.swift
//  NetIdMobileSdk
//
//  Created by Tobias Riesbeck on 03.02.26.
//

import Foundation

public struct NetIdPrivacySettingsIabTcString: Decodable, Encodable, CustomStringConvertible {
    public let value: String
    public let changedAt: String

    public init(value: String, changedAt: String) {
        self.value = value
        self.changedAt = changedAt
    }

    private enum CodingKeys: String, CodingKey {
        case value
        case changedAt = "changed_at"
    }

    public var description: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(changedAt, forKey: .changedAt)
    }
}
