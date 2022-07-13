//
// Created by Tobias Riesbeck on 07/13/2022.
//

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
