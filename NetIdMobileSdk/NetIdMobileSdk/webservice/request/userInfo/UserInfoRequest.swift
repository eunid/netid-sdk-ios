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

class UserInfoRequest: BaseRequest {
    
    private let userinfoEndpoint: URL
    private let accessToken: String
    
    init(userinfoEndpoint: URL, accessToken: String) {
        self.userinfoEndpoint = userinfoEndpoint
        self.accessToken = accessToken
        super.init()
    }
    
    override func getHttpMethod() -> HttpMethod {
        .get
    }
    
    override func addHttpHeaderFields(_ httpHeaderFields: inout [String: String]) {
        httpHeaderFields[WebserviceConstants.AUTHORIZATION_HTTP_HEADER_KEY] =
        WebserviceConstants.AUTHORIZATION_HTTP_HEADER_BEARER + accessToken
    }
    
    override func getScheme() -> String {
        WebserviceConstants.PROTOCOL
    }
    
    override func getHost() -> String {
        userinfoEndpoint.host ?? ""
    }
    
    override func getPath() -> String {
        WebserviceConstants.USER_INFO
    }
    
    func getUserinfoEndpoint() -> URL {
        userinfoEndpoint
    }

}
