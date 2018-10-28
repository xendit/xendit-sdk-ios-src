//
//  Authenticate3DSScreen.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 26/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest


class Authenticate3DSScreen {
    private let app: XCUIApplication

    let title = "3DS Authentication"

    var tokenIDTextField: XCUIElement { return app.textFields["Token ID"] }
    var cvnTextField: XCUIElement { return app.textFields["Card CVN"] }
    var amountTextField: XCUIElement { return app.textFields["Amount"] }

    var submitButton: XCUIElement { return app.buttons["Authentificate"] }

    var successAlert: XCUIElement { return app.alerts["Token"] }

    init(app: XCUIApplication) {
        self.app = app
    }
}
