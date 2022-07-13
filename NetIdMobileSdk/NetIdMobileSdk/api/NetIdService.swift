//
// Created by Felix Hug on 13.07.22.
//

import Foundation

class NetIdService: NSObject {

    static let sharedInstance = NetIdService()
    private var netIdConfig: NetIdConfig?

    public func setConfig(netIdConfig: NetIdConfig) {
        if self.netIdConfig != nil {
            print("Configuration already been set.")
        } else {
            self.netIdConfig = netIdConfig
        }
    }

    public func authorize() {}
}