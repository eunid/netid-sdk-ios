//
// Created by Felix Hug on 09.08.22.
//

import Foundation

public protocol PermissionManagerDelegate: AnyObject {

    func didFetchPermissions(_ permissions: Permissions)

    func didFetchPermissionsWithError(_ error: NetIdError)

    func didUpdatePermission()

    func didUpdatePermissionWithError(_ error: NetIdError)
}