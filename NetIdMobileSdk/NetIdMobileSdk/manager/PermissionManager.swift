//
// Created by Felix Hug on 09.08.22.
//

import Foundation

class PermissionManager: NSObject {
    private var delegate: PermissionManagerDelegate?

    public func fetchPermissions(accessToken: String) {
        let permissionReadRequest = PermissionReadRequest(accessToken: accessToken)
        Webservice.shared.performRequest(permissionReadRequest, callback: { data, error in
            guard let data = data else {
                self.delegate?.didFetchPermissionsWithError(NetIdError(code: .Unknown, process: .PermissionRead))
                return
            }

            if let permissions = try? JSONDecoder().decode(Permissions.self, from: data) {
                self.delegate?.didFetchPermissions(permissions)
            } else {
                self.delegate?.didFetchPermissionsWithError(NetIdError(code: .JsonDeserializationError, process: .PermissionRead))
            }
        })
    }

    public func updatePermissions(accessToken: String) {
        let permissionReadRequest = PermissionWriteRequest(accessToken: accessToken)
        Webservice.shared.performRequest(permissionReadRequest, callback: { data, error in
            guard let data = data else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .Unknown, process: .PermissionRead))
                return
            }

            //TODO parse correct model
            if let permission = try? JSONDecoder().decode(Permissions.self, from: data) {
                self.delegate?.didUpdatePermission()
            } else {
                self.delegate?.didUpdatePermissionWithError(NetIdError(code: .JsonDeserializationError, process: .PermissionWrite))
            }
        })
    }
}
