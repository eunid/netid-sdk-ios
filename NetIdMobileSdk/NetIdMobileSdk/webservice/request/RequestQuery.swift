//
// Created by Tobias Riesbeck on 07/13/2022.
//

import Foundation

class RequestQuery {

    private var parameters = [String: String]()

    func addParameter(_ parameter: String, withValue value: String) {
        parameters[parameter] = value
    }

    func createQueryItems() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for parameterName in parameters.keys {
            let item = URLQueryItem(name: parameterName, value: parameters[parameterName])
            queryItems.append(item)
        }
        return queryItems
    }
}
