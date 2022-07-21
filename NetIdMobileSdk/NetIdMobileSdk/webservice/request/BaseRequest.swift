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

class BaseRequest {

    func getHttpMethod() -> HttpMethod {
        .get
    }

    func addRequestParameters(_ requestQuery: RequestQuery) {

    }

    func addHttpHeaderFields(_ httpHeaderFields: inout [String: String]) {

    }

    func getHttpBody() -> String? {
        nil
    }

    func getScheme() -> String {
        fatalError("Not implemented")
    }

    func getHost() -> String {
        fatalError("Not implemented")
    }
    
    func getPath() -> String {
        fatalError("Not implemented")
    }

    final func getUrlComponents() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = getScheme()
        urlComponents.host = getHost()
        urlComponents.path = getPath()
        urlComponents.queryItems = getRequestQuery().createQueryItems()

        return urlComponents
    }

    final func getRequestQuery() -> RequestQuery {
        let query = RequestQuery()
        addRequestParameters(query)
        return query
    }

    final func getHttpHeaderFields() -> [String: String] {
        var headerFields = [String: String]()
        addHttpHeaderFields(&headerFields)
        return headerFields
    }
}
