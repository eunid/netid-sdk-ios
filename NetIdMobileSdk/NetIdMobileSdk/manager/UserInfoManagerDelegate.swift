//
// Created by Felix Hug on 09.08.22.
//

import Foundation

protocol UserInfoManagerDelegate: AnyObject {

    func didFetchUserInfo(_ userInfo: UserInfo)

    func didFetchUserInfoWithError(_ error: NetIdError)
}