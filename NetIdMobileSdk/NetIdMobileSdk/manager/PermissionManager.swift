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

class PermissionManager: NSObject {
    private weak var delegate: PermissionManagerDelegate?

    init(delegate: PermissionManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }

    public func fetchPermissions(accessToken: String, collapseSyncId: Bool) {
        let permissionReadRequest = PermissionReadRequest(accessToken: accessToken, collapseSyncId: collapseSyncId)
        Webservice.shared.performRequest(permissionReadRequest, callback: { data, permissionResponseStatus, error in
            guard (error == nil) else {
                self.delegate?.didFetchPermissionsWithError(permissionResponseStatus, error!)
                return
            }

            guard let data = data else {
                self.delegate?.didFetchPermissionsWithError(permissionResponseStatus, error!)
                return
            }

            if let permissions = try? JSONDecoder().decode(PermissionReadResponse.self, from: data) {
                self.delegate?.didFetchPermissions(permissions)
            } else {
                self.delegate?.didFetchPermissionsWithError(permissionResponseStatus, NetIdError(code: .JsonDeserializationError, process: .PermissionRead))
            }
        })
    }

    public func updatePermission(accessToken: String, permission: NetIdPermissionUpdate, collapseSyncId: Bool) {
        let permissionWriteRequest = PermissionWriteRequest(accessToken: accessToken, permission: permission,
                collapseSyncId: collapseSyncId)
        Webservice.shared.performRequest(permissionWriteRequest, callback: { data, permissionResponseStatus, error in
            guard (error == nil) else {
                self.delegate?.didUpdatePermissionWithError(permissionResponseStatus, error!)
                return
            }
            
            guard let data = data else {
                self.delegate?.didUpdatePermissionWithError(permissionResponseStatus, error!)
                return
            }

            if let permissionUpdateResponseJson = try? JSONDecoder().decode(PermissionUpdateResponse.self, from: data) {
                self.delegate?.didUpdatePermission(permissionUpdateResponseJson.subjectIdentifiers)
            } else {
                self.delegate?.didUpdatePermissionWithError(permissionResponseStatus, NetIdError(code: .JsonDeserializationError, process: .PermissionWrite))
            }
        })
    }
}
