//
// Created by Felix Hug on 14.07.22.
//

import Foundation

protocol NetIdServiceDelegate: AnyObject {
    func didReceiveToken(_ accessToken: String)

    func didReceiveError(_ error: NetIdError)
}