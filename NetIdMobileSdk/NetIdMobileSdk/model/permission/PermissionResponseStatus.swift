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

public enum PermissionResponseStatus: String, Encodable, Decodable {
    case PERMISSIONS_FOUND = "PERMISSIONS_FOUND",
         PERMISSIONS_NOT_FOUND = "PERMISSIONS_NOT_FOUND",
         PERMISSION_PARAMETERS_ERROR = "PERMISSION_PARAMETERS_ERROR",
         NO_TOKEN = "NO_TOKEN",
         TOKEN_ERROR = "TOKEN_ERROR",
         NO_PERMISSIONS = "NO_PERMISSIONS",
         JSON_PARSE_ERROR = "JSON_PARSE_ERROR",
         NO_REQUEST_BODY = "NO_REQUEST_BODY",
         TAPP_NOT_ALLOWED = "TAPP_NOT_ALLOWED",
         TPID_EXISTENCE_ERROR = "TPID_EXISTENCE_ERROR",
         NO_TPID = "NO_TPID",
         NO_TAPP_ID = "NO_TAPP_ID",
         TAPP_ERROR = "TAPP_ERROR",
         ID_CONSENT_REQUIRED = "ID_CONSENT_REQUIRED",
         UNKNOWN = "UNKNOWN"
}
