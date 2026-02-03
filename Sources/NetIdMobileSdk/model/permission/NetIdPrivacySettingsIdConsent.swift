//
//  NetIdPrivacySettingsIdConsent.swift
//  NetIdMobileSdk
//
//  Created by Tobias Riesbeck on 03.02.26.
//

import Foundation

public struct NetIdPrivacySettingsIdConsent: Decodable, Encodable, CustomStringConvertible {
    public let status: NetIdPermissionStatus?
    public let changedAt: String

    public init(status: NetIdPermissionStatus, changedAt: String) {
        self.status = status
        self.changedAt = changedAt
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case changedAt = "changed_at"
    }

    public var description: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(changedAt, forKey: .changedAt)
    }
}
