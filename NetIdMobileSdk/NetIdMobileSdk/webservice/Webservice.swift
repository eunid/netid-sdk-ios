//
// Created by Tobias Riesbeck on 07/13/2022.
//

import Foundation

class Webservice {

    static let shared = Webservice()

    private let session = URLSession.shared
    private let log = Logger.shared

    private init() {

    }

    func performRequest(_ request: BaseRequest, callback: @escaping (_ responseData: Dictionary<String, Any>?, _ error: Error?) -> Void) {
        guard let url = request.getUrlComponents().url else {
            log.error("Unable to get components URL")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.getHttpMethod().rawValue
        urlRequest.httpBody = request.getHttpBody()?.data(using: String.Encoding.utf8)

        let httpHeaderFields = request.getHttpHeaderFields()
        for headerField in httpHeaderFields {
            urlRequest.setValue(headerField.value, forHTTPHeaderField: headerField.key)
        }

        let task = session.dataTask(with: urlRequest) { [self] data, response, error in
            guard error == nil else {
                log.error("Request error: " + (error?.localizedDescription ?? "") + " for URL: " + (urlRequest.url?.absoluteString ?? ""))
                DispatchQueue.main.async {
                    callback(nil, error)
                }
                return
            }

            if let data = data {
                do {
                    let jsonResponseObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let responseDictionary = jsonResponseObject as? Dictionary<String, Any> {
                        DispatchQueue.main.async {
                            callback(responseDictionary, nil)
                        }
                    } else {
                        log.error("Response data has an invalid format")
                        DispatchQueue.main.async {
                            callback(nil, nil)
                        }
                    }
                } catch {
                    log.error("Response data is invalid")
                    DispatchQueue.main.async {
                        callback(nil, nil)
                    }
                }
            } else {
                log.error("Response does not contain any data")
                DispatchQueue.main.async {
                    callback(nil, nil)
                }
            }
        }
        task.resume()
    }
}
