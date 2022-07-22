//
//  ServiceViewModel.swift
//  NetIdMobileSdk-App
//
//  Created by Tobias Riesbeck on 22.07.22.
//

import Foundation
import SwiftUI

class ServiceViewModel: ObservableObject {

    @Published var initializationEnabled = true
    @Published var authenticationEnabled = false

    @Published var initializationStatusColor = Color.gray
    @Published var authenticationStatusColor = Color.gray

    @Published var logText = "Logs:\n\n"

    func initializeNetIdService() {
        initializationEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.initializationStatusColor = Color.green
            self.logText.append("Net ID service initialized successfully\n")
            self.authenticationEnabled = true
        })
    }

    func authorizeNetIdService() {
        authenticationEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.authenticationStatusColor = Color.green
            self.logText.append("Net ID service authorized successfully\n")
        })
    }
}
