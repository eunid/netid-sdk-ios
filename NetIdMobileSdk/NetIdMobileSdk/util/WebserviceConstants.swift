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

struct WebserviceConstants {
    static let PROTOCOL = "https"
    static let USER_INFO = "/userinfo"
    static let AUTHORIZATION_HTTP_HEADER_KEY = "Authorization"
    static let AUTHORIZATION_HTTP_HEADER_BEARER = "Bearer "
    static let ACCEPT_HEADER_KEY = "Accept"
    static let CONTENT_TYPE_HEADER_KEY = "Content-Type"
    static let CONTENT_TYPE_PERMISSION_WRITE = "application/vnd.netid.permission-center.netid-permissions-v2+json"
    static let ACCEPT_HEADER_PERMISSION_WRITE_AUDIT = "application/vnd.netid.permission-center.netid-subject-status-audit-v1+json"
    static let ACCEPT_HEADER_PERMISSION_WRITE = "application/vnd.netid.permission-center.netid-user-status-v1+json"
    static let ACCEPT_HEADER_PERMISSION_READ_AUDIT = "application/vnd.netid.permission-center.netid-user-status-audit-v1+json"
    static let ACCEPT_HEADER_PERMISSION_READ = "application/vnd.netid.permission-center.netid-user-status-v1+json"
    static let PERMISSION_READ_HOST = "einwilligungsspeicher.netid.de"
    static let PERMISSION_READ_PATH = "/netid-user-status"
    static let PERMISSION_WRITE_HOST = "einwilligen.netid.de"
    static let PERMISSION_WRITE_PATH = "/netid-permissions"
}
