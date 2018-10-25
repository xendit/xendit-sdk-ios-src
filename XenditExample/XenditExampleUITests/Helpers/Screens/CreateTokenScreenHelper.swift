//
//  CreateTokenScreenHelper.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 25/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest


class CreateTokenScreenHelper {
    private let app: XCUIApplication

    let title = "Create Token"

    var cardNumberTextField: XCUIElement { return app.textFields["Card Number"] }
    var expiryMonthTextField: XCUIElement { return app.textFields["Exp Month"] }
    var expiryYearTextField: XCUIElement { return app.textFields["Exp Year"] }
    var cvnTextField: XCUIElement { return app.textFields["Cvn"] }
    var amountTextField: XCUIElement { return app.textFields["Amount"] }
    var multipleUseSwitch: XCUIElement { return app.switches["Multiple Use"] }
    var createTokenButton: XCUIElement { return app.buttons["Create token"] }

    var successAlert: XCUIElement { return app.alerts["Token"] }

    init(app: XCUIApplication) {
        self.app = app
    }
}
