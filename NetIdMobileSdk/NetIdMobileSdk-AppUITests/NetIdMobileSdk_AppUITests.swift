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

import XCTest

class NetIdMobileSdk_AppUITests: XCTestCase {

    private let app = XCUIApplication()
    
    // These consts define data for logging into one of the account provider.
    // These value have to be adjusted.
    private let LOGIN = "mail@web.de"
    private let PASSWORD = "secret_password"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Always start in portrait mode
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        sleep(2)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Make sure the app is dead
        XCUIApplication().terminate()
        
        // Always start in portrait mode
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        sleep(2)
    }
    
    // Helper function to search for a certain string in the logs.
    func findInLog(search: String) -> Bool {
        let log = app.staticTexts["LogView"]
        XCTAssertTrue(log.exists)
        let lines = log.label.components(separatedBy: "\n")
        for line in lines {
            if (line.hasPrefix(search)) {
                return true
            }
        }
        return false
    }

    // All buttons but the first one have to be disabled at start.
    func testButtonStatesAtStartup() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Authorisieren"].isEnabled)
        XCTAssertFalse(app.buttons["UserInfo laden"].isEnabled)
        XCTAssertFalse(app.buttons["Laden"].isEnabled)
        XCTAssertFalse(app.buttons["Aktualisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Session beenden"].isEnabled)
    }

    // Test log functionality.
    func testLog() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Service initialisieren"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service initialized successfully"))
    }
    
    // Start with a login flow but cancel it before entering the web view.
    func testLoginFlowCancel() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Service initialisieren"].tap()
        sleep(2)
        XCTAssertFalse(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Authorisieren"].tap()
        sleep(2)

        let alert = app.alerts["Bitte wähle Deinen Authorisierungsprozess."]
        XCTAssertTrue(alert.exists)
        alert.buttons["Login"].tap()
        app.buttons["Weitere Anmeldeoptionen"].tap()
        XCTAssertFalse(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Weitere Anmeldeoptionen"].exists)
        XCTAssertTrue(findInLog(search: "netID service user did cancel authentication in process: Authentication"))
    }

    // Do complete login flow cycle.
    func testLoginFlowOkay() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Service initialisieren"].tap()
        sleep(2)
        XCTAssertFalse(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Authorisieren"].tap()
        sleep(2)

        app.alerts["Bitte wähle Deinen Authorisierungsprozess."].scrollViews.otherElements.buttons["Login"].tap()
        app.buttons["Login mit netID"].tap()
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertTrue(alert.exists)
        alert.buttons["Fortfahren"].tap()
        
        // Catch the webview
        sleep(2)
        let webViewQuery:XCUIElementQuery = app.descendants(matching: .webView)
        let webView = webViewQuery.element(boundBy: 0)
        
        // If there was a login (or attempt) at a former time, we first need to go back one step.
        let link = webView.staticTexts["E-Mail-Adresse ändern"]
        if (link.exists) {
            link.tap()
            sleep(2)
        }

        let mail = webView.textFields.element(boundBy: 0)
        mail.tap()
        mail.typeText(LOGIN)
        XCTAssertEqual(LOGIN, mail.value as! String)
        webView.buttons["Weiter"].tap()
        
        let password = webView.secureTextFields["Passwort"]
        password.tap()
        password.typeText(PASSWORD)
        sleep(2)
        webView.buttons["Login"].tap()
        sleep(2)
        webView.buttons["Daten übermitteln"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service authorized successfully"))

        app.buttons["Laden"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service permission - fetch failed with error: UnauthorizedClient"))
        app.buttons["Aktualisieren"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service permission - update failed with error: UnauthorizedClient"))
        app.buttons["UserInfo laden"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service user info - fetch finished successfully:"))

        // At the end, we end the session and test if the "Authorisieren" button is enabled again.
        app.buttons["Session beenden"].tap()
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
    }

    // Do complete permission flow cycle.
    func testPermissionFlowOkay() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Service initialisieren"].tap()
        sleep(2)
        XCTAssertFalse(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
        app.buttons["Authorisieren"].tap()

        app.alerts["Bitte wähle Deinen Authorisierungsprozess."].scrollViews.otherElements.buttons["Permission"].tap()
        app.buttons["Zustimmen mit netID"].tap()
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        XCTAssertTrue(alert.exists)
        alert.buttons["Fortfahren"].tap()
        
        // Catch the webview
        sleep(2)
        let webViewQuery:XCUIElementQuery = app.descendants(matching: .webView)
        let webView = webViewQuery.element(boundBy: 0)
        
        // If there was a login (or attempt) at a former time, we first need to go back one step.
        let link = webView.staticTexts["E-Mail-Adresse ändern"]
        if (link.exists) {
            link.tap()
            sleep(2)
        }
        let mail = webView.textFields.element(boundBy: 0)
        mail.tap()
        mail.typeText(LOGIN)
        XCTAssertEqual(LOGIN, mail.value as! String)
        webView.buttons["Weiter"].tap()
        
        let password = webView.secureTextFields["Passwort"]
        password.tap()
        password.typeText(PASSWORD)
        sleep(2)
        webView.buttons["Login"].tap()
        sleep(2)
        app.buttons["Laden"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service permission - fetch finished successfully"))
        app.buttons["Aktualisieren"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service permission - update finished successfully"))
        app.buttons["UserInfo laden"].tap()
        sleep(2)
        XCTAssertTrue(findInLog(search: "netID service user info - fetch failed: NoAuth"))

        // At the end, we end the session and test if the "Authorisieren" button is enabled again.
        app.buttons["Session beenden"].tap()
        XCTAssertTrue(app.buttons["Authorisieren"].isEnabled)
    }

    
    func testExtraClaimsOnlyBeforeInitialising() throws {
        XCTAssertTrue(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertTrue(app.switches["shipping_address"].isEnabled)
        XCTAssertTrue(app.switches["birthdate"].isEnabled)
        app.buttons["Service initialisieren"].tap()
        XCTAssertFalse(app.buttons["Service initialisieren"].isEnabled)
        XCTAssertFalse(app.switches["shipping_address"].isEnabled)
        XCTAssertFalse(app.switches["birthdate"].isEnabled)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
