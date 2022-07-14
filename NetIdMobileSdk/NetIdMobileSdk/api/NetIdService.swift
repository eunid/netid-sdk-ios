//
// Created by Felix Hug on 13.07.22.
//

import Foundation

class NetIdService: NSObject {

    static let sharedInstance = NetIdService()
    private var netIdConfig: NetIdConfig?
    private var netIdListener: [NetIdServiceDelegate] = []

    public func registerListener(_ listener: NetIdServiceDelegate){
        netIdListener.append(listener)
    }

    public func initialize(_ netIdConfig: NetIdConfig) {
        if self.netIdConfig != nil {
            print("Configuration already been set.")
        } else {
            self.netIdConfig = netIdConfig
            // TODO fetch configuration from .well-known endpoint
        }
    }

    public func authorize() {}
}