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
import AppAuth

class AppAuthManager: NSObject {
    private var delegate: AppAuthManagerDelegate?

    init(delegate: AppAuthManagerDelegate?) {
        self.delegate = delegate
        super.init()
    }

    public func fetchConfiguration(_ host: String) {
        var urlComponents = URLComponents()
        urlComponents.host = host
        urlComponents.path = WebserviceConstants.WELL_KNOWN_CONFIG_PATH
        urlComponents.scheme = WebserviceConstants.PROTOCOL
        if let url = urlComponents.url {
            OIDAuthorizationService.discoverConfiguration(forDiscoveryURL: url) { [self] configuration, error in
                if error == nil {
                    delegate?.didReceiveConfig()
                } else {
                    delegate?.didReceiveError()
                }
            }
        }
    }

    public func requestAuthorizationCode() {

    }
}