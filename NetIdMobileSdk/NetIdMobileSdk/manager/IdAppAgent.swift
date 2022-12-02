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
import AppAuthCore

/**
 An implementation of [OIDExternalUserAgent] for making use of id apps as external user-agents.
 */
class IdAppAgent: NSObject, OIDExternalUserAgent {

    private var externalUserAgentFlowInProgress: Bool = false
    private var session: OIDExternalUserAgentSession? = nil
    private var request: OIDExternalUserAgentRequest? = nil

    override init() {
        super.init()
        externalUserAgentFlowInProgress = false
    }

    public func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        // return if a flow is already running
        if(externalUserAgentFlowInProgress){
            return false
        }

        externalUserAgentFlowInProgress = true
        self.session = session
        self.request = request

        // Note that we cannot handle an error via the completionhandler as it is asychronos
        UIApplication.shared.open(
            request.externalUserAgentRequestURL(),
            options: [.universalLinksOnly : true]) { started in
                // if not started cancel with error
                if(!started) {
                    let url = (self.request?.externalUserAgentRequestURL().absoluteString) ?? "Unknown"
                    let error = OIDErrorUtilities.error(
                        with: OIDErrorCode.browserOpenError,
                        underlyingError: nil,
                        description: "Failed to open Universal Link: " + url)
                    self.cleanup()
                    session.failExternalUserAgentFlowWithError(error)
                }
            }
        return true
    }

    public func dismiss(animated: Bool, completion: @escaping () -> Void) {
        if(!externalUserAgentFlowInProgress){
            return
        }
        cleanup()
        completion()
    }

    private func cleanup(){
        externalUserAgentFlowInProgress = false
        session = nil
        request = nil
    }

}
