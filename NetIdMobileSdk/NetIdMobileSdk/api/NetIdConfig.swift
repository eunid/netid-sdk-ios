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

public struct LoginLayerConfig {
    public var headlineText: String
    public var loginText: String
    public var continueText: String
    
    public init () {
        self.headlineText = ""
        self.loginText = ""
        self.continueText = ""
    }
}

public struct PermissionLayerConfig {
    public var logoId: String
    public var headlineText: String
    public var legalText: String
    public var continueText: String
    
    public init() {
        self.logoId = ""
        self.headlineText = ""
        self.legalText = ""
        self.continueText = ""
    }
}

public struct NetIdConfig {
    public var host: String
    public var clientId: String
    public var redirectUri: String
    public var originUrlScheme: String
    public var claims: [String: String]?
    public var loginLayerConfig: LoginLayerConfig?
    public var permissionLayerConfig: PermissionLayerConfig?

    public init(host: String, clientId: String, redirectUri: String, originUrlScheme: String, claims: [String: String]?, loginLayerConfig: LoginLayerConfig?, permissionLayerConfig: PermissionLayerConfig?) {
        self.host = host
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.originUrlScheme = originUrlScheme
        self.claims = claims
        self.loginLayerConfig = loginLayerConfig
        self.permissionLayerConfig = permissionLayerConfig
    }
}
