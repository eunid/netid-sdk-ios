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

    /**
      * Performs a web request to fetch information, permissions, or set permissions related to an authorized user.
      * The result of the request is provided via the given callback instance.
      *
      * @param request a request to make, can be any of [UserInfoRequest], [PermissionReadRequest] or [PermissionWriteRequest]
      * @param callback a callback instance receiving callbacks when the request is complete
      */
    func performRequest(_ request: BaseRequest, callback: @escaping (_ responseData: Data?, _ permissionResponseStatus: PermissionResponseStatus, _ error: NetIdError?) -> Void) {
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
            var errorProcess = NetIdErrorProcess.Configuration
            var statusCode = PermissionResponseStatus.UNKNOWN

            let body = (data != nil) ? String(decoding: data!, as: UTF8.self) : ""
            switch request {
            case is PermissionReadRequest:
                errorProcess = .PermissionRead
            case is PermissionWriteRequest:
                errorProcess = .PermissionWrite
            case is UserInfoRequest:
                errorProcess = .UserInfo
            default:
                DispatchQueue.main.async {
                    callback(nil, statusCode, nil)
                }
            }

            guard error == nil else {
                log.error("Request error: " + (error?.localizedDescription ?? "") + " for URL: " + (urlRequest.url?.absoluteString ?? ""))
                let err = NetIdError(code: .Unknown, process: errorProcess, msg: error?.localizedDescription)

                DispatchQueue.main.async {
                    callback(nil, statusCode, err)
                }
                return
            }
            let httpResponse = response as! HTTPURLResponse
            
            // We got back a response, but the HTTP error code does not signal a successful call.
            if (httpResponse.statusCode > 299) {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                var errorCode = NetIdErrorCode.Unknown
                if let responseJSON = responseJSON as? [String: Any]  {
                    switch request {
                    case is PermissionReadRequest:
                        statusCode = PermissionResponseStatus(rawValue: responseJSON["status_code"] as! String) ?? .UNKNOWN
                        errorCode = (statusCode  == PermissionResponseStatus.TPID_EXISTENCE_ERROR) ? NetIdErrorCode.Other : NetIdErrorCode.InvalidRequest
                    case is PermissionWriteRequest:
                        statusCode = PermissionResponseStatus(rawValue: responseJSON["status_code"] as! String) ?? .UNKNOWN
                        errorCode = (statusCode  == PermissionResponseStatus.TPID_EXISTENCE_ERROR) ? NetIdErrorCode.Other : NetIdErrorCode.InvalidRequest
                    case is UserInfoRequest:
                        statusCode = .UNKNOWN
                        if httpResponse.statusCode == 401 {
                            errorCode = .UnauthorizedClient
                        } else {
                            errorCode = .InvalidRequest
                        }
                    default:
                        DispatchQueue.main.async {
                            callback(nil, statusCode, nil)
                        }
                    }
                }
                let err = NetIdError(code: errorCode, process: errorProcess, msg: body)
                
                DispatchQueue.main.async {
                    callback(nil, statusCode, err)
                }
                return
            }

            // The call was successful, check if we got back data, too.
            // This should never fail, but we will yield an error just in case.
            if let data = data {
                DispatchQueue.main.async {
                    callback(data, statusCode, nil)
                }
            } else {
                log.error("Response does not contain any data")
                DispatchQueue.main.async {
                    callback(nil, statusCode, nil)
                }
            }
        }
        task.resume()
    }
}
