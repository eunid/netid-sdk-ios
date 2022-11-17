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
        Webservice.shared.performRequest(permissionReadRequest, callback: { data, error in
            guard (error == nil) else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .InvalidRequest, process: .PermissionRead), originalError: error)
                return
            }

            guard let data = data else {
                self.delegate?.didFetchPermissionsWithError(NetIdError(code: .Unknown, process: .PermissionRead), originalError: error)
                return
            }

            if let permissions = try? JSONDecoder().decode(Permissions.self, from: data) {
                self.delegate?.didFetchPermissions(permissions)
            } else {
                self.delegate?.didFetchPermissionsWithError(NetIdError(code: .JsonDeserializationError, process: .PermissionRead), originalError: error)
            }
        })
    }

    public func updatePermission(accessToken: String, permission: NetIdPermissionUpdate, collapseSyncId: Bool) {
        let permissionWriteRequest = PermissionWriteRequest(accessToken: accessToken, permission: permission,
                collapseSyncId: collapseSyncId)
        Webservice.shared.performRequest(permissionWriteRequest, callback: { data, error in
            guard (error == nil) else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .InvalidRequest, process: .PermissionWrite), originalError: error)
                return
            }
            
            guard let data = data else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .Unknown, process: .PermissionWrite), originalError: error)
                return
            }

            if let permissionJson = try? JSONDecoder().decode(SubjectIdentifiers.self, from: data) {
                self.delegate?.didUpdatePermission(permissionJson)
            } else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .JsonDeserializationError, process: .PermissionWrite), originalError: error)
            }
        })
    }
}
