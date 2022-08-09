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

public protocol NetIdServiceDelegate: AnyObject {
    func didFinishInitializationWithError(_ error: NetIdError?)
    
    func didFinishAuthentication(_ accessToken: String)
    
    func didFinishAuthenticationWithError(_ error: NetIdError?)

    func didFetchUserInfo(_ userInfo: UserInfo)

    func didFetchUserInfoWithError(_ error: NetIdError)

    func didEndSession()

    func didEncounterNetworkError(_ error: NetIdError)

    func didCancelAuthentication(_ error: NetIdError)

    func didFetchPermissions(_ permissions: Permissions)

    func didFetchPermissionsWithError(_ error: NetIdError)

    func didUpdatePermission()

    func didUpdatePermissionWithError(_ error: NetIdError)

}
