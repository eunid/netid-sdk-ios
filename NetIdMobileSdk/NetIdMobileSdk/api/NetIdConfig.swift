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

public struct NetIdConfig {
    /// Name of the host that acts as an SSO broker, e.g. broker.netid.de.
    public var host: String
    /// The client id of this application. You need to retrieve it from the netID developer portal.
    public var clientId: String
    /// Redirect URI for your application. Used when using the app2web flow.
    public var redirectUri: String
    /// Custom scheme to preceed deep links with - is this still neccessary?
    public var originUrlScheme: String
    /// Additional claims to set.
    public var claims: [String: String]?

    /// Initialize the SDK. This is the first thing to do.
    public init(host: String = "broker.netid.de", clientId: String, redirectUri: String, originUrlScheme: String, claims: [String: String]?) {
        self.host = host
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.originUrlScheme = originUrlScheme
        self.claims = claims
    }
}
