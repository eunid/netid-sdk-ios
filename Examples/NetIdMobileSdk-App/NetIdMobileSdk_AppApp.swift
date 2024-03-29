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

import SwiftUI

/**
 This a sample appliaction, that demonstrates the use of the ``NetIdMobileSdk``.
 Basically, this app provides a step-by-step approach for using the authorization flow of the sdk.
 * Initialize the sdk.
 * Choose which flow to use for authorization.
 * Authorize using the desired flow (a bootom sheet is presented for this step).
 * End session.
 
 */

@main
struct NetIdMobileSdk_AppApp: App {

    @StateObject private var serviceViewModel = ServiceViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                serviceViewModel.resumeSession(url)
            })
            .environmentObject(serviceViewModel)
        }
    }
}
