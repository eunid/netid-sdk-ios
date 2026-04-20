//
//  FetchOptionsUtil.swift
//  NetIdMobileSdk
//
//  Created by Tobias Riesbeck on 30.01.26.
//

final class FetchOptionsUtil {
    private init() {}

    static func queryParameterValue(for fetchOptions: Set<NetIdIdentifierOption>, collapseSyncId: Bool) -> String {
        let legacyFetchOptions: [NetIdIdentifierOption] = if fetchOptions.isEmpty {
            collapseSyncId ? [.tagProtocolIdentifier] : [.tagProtocolIdentifier, .synchronizationIdentifier]
        } else {
            fetchOptions.map { $0 }
        }
        return legacyFetchOptions.map { $0.rawValue }.joined(separator: ",")
    }
}
