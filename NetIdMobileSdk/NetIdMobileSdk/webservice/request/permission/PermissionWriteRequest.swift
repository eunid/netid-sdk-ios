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

class PermissionWriteRequest: BaseRequest {

    private let accessToken: String
    private let permission: NetIdPermissionUpdate

    init(accessToken: String, permission: NetIdPermissionUpdate) {
        self.accessToken = accessToken
        self.permission = permission
        super.init()
    }

    override func getHttpMethod() -> HttpMethod {
        .post
    }

    override func getHttpBody() -> String? {
        if let jsonData = try? JSONEncoder().encode(permission) {
            return String(data: jsonData, encoding: .utf8)
        } else {
            return nil
        }
    }

    override func addHttpHeaderFields(_ httpHeaderFields: inout [String: String]) {
        httpHeaderFields[WebserviceConstants.AUTHORIZATION_HTTP_HEADER_KEY] =
                WebserviceConstants.AUTHORIZATION_HTTP_HEADER_BEARER + accessToken
        httpHeaderFields[WebserviceConstants.ACCEPT_HEADER_KEY] =
                WebserviceConstants.ACCEPT_HEADER_PERMISSION_WRITE
        httpHeaderFields[WebserviceConstants.CONTENT_TYPE_HEADER_KEY] =
                WebserviceConstants.CONTENT_TYPE_PERMISSION_WRITE
    }

    override func getScheme() -> String {
        WebserviceConstants.PROTOCOL
    }

    override func getHost() -> String {
        WebserviceConstants.PERMISSION_WRITE_HOST
    }

    override func getPath() -> String {
        WebserviceConstants.PERMISSION_WRITE_PATH
    }
}