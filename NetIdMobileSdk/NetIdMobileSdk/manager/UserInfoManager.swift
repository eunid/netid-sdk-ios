//
// Created by Felix Hug on 09.08.22.
//

import Foundation

class UserInfoManager: NSObject {
    private var delegate: UserInfoManagerDelegate?

    /**
     Fetches the UserInfo.
     */
    public func fetchUserInfo(host: String, accessToken: String) {
        let userInfoRequest = UserInfoRequest(host: host, accessToken: accessToken)
        Webservice.shared.performRequest(userInfoRequest, callback: { data, error in
            guard let data = data else {
                self.delegate?.didFetchUserInfoWithError(NetIdError(code: .Unknown, process: .UserInfo)
                )
                return
            }

            if let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) {
                self.delegate?.didFetchUserInfo(userInfo)
            } else {
                self.delegate?.didFetchUserInfoWithError(NetIdError(code: .JsonDeserializationError, process: .UserInfo))
            }
        })
    }
}