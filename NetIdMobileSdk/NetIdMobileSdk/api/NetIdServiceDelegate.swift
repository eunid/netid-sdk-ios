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
    
    /**
     Delegate function that gets called when the SDK could not be initialized correctly.
     In this case, a ``NetIdError`` is returned which holds more information about the error.
     - Parameter Error description.
     */
    func didFinishInitializationWithError(_ error: NetIdError?)
    
    /**
     Delegate function that gets called when the authentication process finished successfully.
     In this case, an access token is returned.
     - Parameter Access token.
     */
    func didFinishAuthentication(_ accessToken: String)
    
    /**
     Delegate function that gets called when user information could not be retrieved.
     In this case, a ``NetIdError`` is returned which holds more information about the error.
     - Parameter Error description.
     */
    func didFinishAuthenticationWithError(_ error: NetIdError?)

    /**
     Delegate function that gets called when user information could be retrieved successfully.
     - Parameter Filled out user information.
     */
    func didFetchUserInfo(_ userInfo: UserInfo)

    /**
     Delegate function that gets called when user information could not be retrieved.
     In this case, a ``NetIdError`` is returned which holds more information about the error.
     - Parameter Error description.
     */
    func didFetchUserInfoWithError(_ error: NetIdError)

    /**
     Delegate function that gets called when a session ends.
     */
    func didEndSession()

    /**
     Delegate function that gets called when a network error occured.
     In this case, a ``NetIdError`` is returned which holds more information about the error.
     - Parameter Error description.
     */
    func didEncounterNetworkError(_ error: NetIdError)

    /**
     Delegate function that gets called when the authentication process got canceled.
     In this case, a ``NetIdError`` is returned which holds more information about the error.
     - Parameter Error description.
     */
    func didCancelAuthentication(_ error: NetIdError)

    /**
     Delegate function that gets called when permissions were fetched successfully.
     - Parameter Fetched permissions.
     */
    func didFetchPermissions(_ permissions: PermissionReadResponse)

    /**
     Delegate function that gets called when user information could not be retrieved.
     In this case, a ``NetIdError`` and ``PermissionResponseStatus``are returned which hold more information about the error.
     - Parameter Status of the last permission command.
     - Parameter Error description.
     */
    func didFetchPermissionsWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError)

    /**
     Delegate function that gets called when permissions were updated successfully.
     - Parameter Updated subject identifiers.
     */
    func didUpdatePermission(_ subjectIdentifiers: SubjectIdentifiers)

    /**
     Delegate function that gets called when permissions could not be updated.
     In this case, a ``NetIdError`` and ``PermissionResponseStatus``are returned which hold more information about the error.
     - Parameter Status of the last permission command.
     - Parameter Error description.
     */
    func didUpdatePermissionWithError(_ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError)

}
