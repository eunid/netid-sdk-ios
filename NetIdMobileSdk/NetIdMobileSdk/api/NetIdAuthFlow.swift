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

/**
 Enumeartion of the flows that are supported by the SDK.
 ``Permission`` sets the scope "permission" only.
 ``Login`` sets the scope "openid" only.
 ``LoginPermission`` sets both the scopes "openid" and "permission"
 */
public enum NetIdAuthFlow {
    case Permission, Login, LoginPermission
}
