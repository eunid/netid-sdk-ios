//
// Created by Felix Hug on 08.08.22.
//

import Foundation

class PermissionWriteRequest: BaseRequest {

    private let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
        super.init()
    }

    override func getHttpMethod() -> HttpMethod {
        .post
    }

    override func getHttpBody() -> String? {
        //TODO add request body
        ""
    }

    override func addHttpHeaderFields(_ httpHeaderFields: inout [String: String]) {
        httpHeaderFields[WebserviceConstants.AUTHORIZATION_HTTP_HEADER_KEY] =
                WebserviceConstants.AUTHORIZATION_HTTP_HEADER_BEARER + accessToken
    }

    override func getScheme() -> String {
        WebserviceConstants.PROTOCOL
    }

    override func getHost() -> String {
        WebserviceConstants.PERMISSION_WRITE_HOST
    }

    override func getPath() -> String {
        WebserviceConstants.PERMISSION_WRITE_PATH
    }
}