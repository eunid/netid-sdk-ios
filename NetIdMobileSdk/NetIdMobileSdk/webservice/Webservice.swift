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

class Webservice {

    static let shared = Webservice()

    private let session = URLSession.shared
    private let log = Logger.shared
        
    private init() {

    }

    func performRequest(_ request: BaseRequest, callback: @escaping (_ responseData: Data?, _ error: Error?) -> Void) {
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
            let httpResponse = response as! HTTPURLResponse
            if (httpResponse.statusCode > 299) {
                let msg = (data != nil) ? String(decoding: data!, as: UTF8.self) : ""
                let err = NSError(domain: "", code: httpResponse.statusCode, userInfo: [ NSLocalizedDescriptionKey: msg])
                
                DispatchQueue.main.async {
                    callback(nil, err)
                }
                return
            }

            if let data = data {
                DispatchQueue.main.async {
                    callback(data, nil)
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
