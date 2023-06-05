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
    /// Sets the text of the headline (beneath the logo). Only visible, if at least one id app is installed.
    public var headlineText: String?
    /// Sets the text of the buttons displayed, if id apps are installed. The name of the app will be displayed as well, if the string is a format string containing  "%s".
    public var loginText: String?
    /// Sets the text of the continue button at the bottom of the dialog. Only visible, if there is no id app installed.
    public var continueText: String?
    
    public init (headlineText: String? = nil, loginText: String? = nil, continueText: String? = nil) {
        self.headlineText = headlineText
        self.loginText = loginText
        self.continueText = continueText
    }
}

public struct PermissionLayerConfig {
    /// References an icon asset by name to be set during permission flow (in the upper left corner of the dialog).
    public var logoName: String?
    /// Sets the text of the headline (beneath the logo).
    public var headlineText: String?
    /// Sets the text of the first part of the legal information text. However, the second part is fixed and can not be set.
    public var legalText: String?
    /// Sets the text of the continue button at the bottom of the dialog.
    public var continueText: String?
    
    public init(logoName: String? = nil, headlineText: String? = nil, legalText: String? = nil, continueText: String? = nil) {
        self.logoName = logoName
        self.headlineText = headlineText
        self.legalText = legalText
        self.continueText = continueText
    }
}

public struct NetIdConfig {
    /// The client id of this application. You need to retrieve it from the netID developer portal.
    public var clientId: String
    /// Redirect URI for your application.  You need to retrieve it from the netID developer portal.
    public var redirectUri: String
    /// Additional claims to set. This needs to be a JSON string,but can be nil.
    public var claims: String?
    /// Additional value for parameter `prompt` that will be used during app2web-flow only.
    public var promptWeb: String?
    /// Optional configuration for strings to display in the login layer.
    public var loginLayerConfig: LoginLayerConfig?
    /// Optional configuration for strings and logo to display in the permission layer.
    public var permissionLayerConfig: PermissionLayerConfig?

    /// Initialize the SDK. This is the first thing to do.
    public init(clientId: String, redirectUri: String, claims: String?, promptWeb: String?, loginLayerConfig: LoginLayerConfig?, permissionLayerConfig: PermissionLayerConfig?) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.claims = claims
        self.promptWeb = promptWeb
        self.loginLayerConfig = loginLayerConfig
        self.permissionLayerConfig = permissionLayerConfig
    }
}
