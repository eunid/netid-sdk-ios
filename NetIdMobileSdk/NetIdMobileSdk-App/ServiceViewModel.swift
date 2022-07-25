//
//  ServiceViewModel.swift
//  NetIdMobileSdk-App
//
//  Created by Tobias Riesbeck on 22.07.22.
//

import Foundation
import NetIdMobileSdk
import SwiftUI

class ServiceViewModel: NSObject, ObservableObject {

    @Published var initializationEnabled = true
    @Published var authenticationEnabled = false
    @Published var userInfoEnabled = false
    @Published var endSessionEnabled = false

    @Published var initializationStatusColor = Color.gray
    @Published var authenticationStatusColor = Color.gray
    @Published var userInfoStatusColor = Color.gray

    @Published var logText = "Logs:\n\n"

    func initializeNetIdService() {
        initializationEnabled = false
        NetIdService.sharedInstance.registerListener(self)
        if let clientID = UUID(uuidString: "26e016e7-54c7-4ffd-bee0-782a9a4f87d6") {
            let config = NetIdConfig(host: "broker.netid.de", clientId: clientID,
                    redirectUri: "net.openid.appauth.Example:/oauth2redirect/example-provider")
            NetIdService.sharedInstance.initialize(config)
        }
    }

    func authorizeNetIdService() {
        authenticationEnabled = false
        if let currentViewController = UIApplication.shared.visibleViewController {
            NetIdService.sharedInstance.authorize(bundleIdentifier: nil, currentViewController: currentViewController)
        }
    }

    func fetchUserInfo() {
        userInfoEnabled = false
        //TODO fetch userinfo
    }

    func endSession() {
        endSessionEnabled = false
        //TODO end current session
    }
}

extension ServiceViewModel: NetIdServiceDelegate {

    func didFinishInitializationWithError(_ error: NetIdError?) {
        if let errorCode = error?.code.rawValue {
            initializationStatusColor = Color.red
            logText.append("Net ID service initialization failed \n" + errorCode + "\n")
        } else {
            initializationStatusColor = Color.green
            logText.append("Net ID service initialized successfully\n")
            authenticationEnabled = true
        }
    }

    func didFinishAuthentication(_ accessToken: String) {
        authenticationStatusColor = Color.green
        userInfoEnabled = true
        endSessionEnabled = true
        logText.append("Net ID service authorized successfully\n" + accessToken + "\n")
    }

    func didFinishAuthenticationWithError(_ error: NetIdError?) {
        authenticationStatusColor = Color.red
        if let errorCode = error?.code.rawValue {
            authenticationStatusColor = Color.red
            logText.append("Net ID service authorization failed \n" + errorCode + "\n")
            authenticationEnabled = true
        } else {
            authenticationStatusColor = Color.green
            logText.append("Net ID service authorization successfully\n")
        }
    }
}
