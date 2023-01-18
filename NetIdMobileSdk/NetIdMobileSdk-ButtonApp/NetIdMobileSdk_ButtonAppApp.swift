//
//  NetIdMobileSdk_ButtonAppApp.swift
//  NetIdMobileSdk-ButtonApp
//
//  Created by Tobias Bachmor on 24.12.22.
//

import SwiftUI
import NetIdMobileSdk

@main
struct NetIdMobileSdk_ButtonAppApp: App {
    
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
