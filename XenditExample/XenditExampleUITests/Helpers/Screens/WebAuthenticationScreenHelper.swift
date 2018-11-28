//
//  WebAuthenticationScreenHelper.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 26/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest


class WebAuthenticationScreenHelper {
    private let app: XCUIApplication

    var titleLabel: XCUIElement { return app.staticTexts["Please submit your Verified by Visa password."] }

    var cancelButton: XCUIElement { return app.navigationBars.buttons["Cancel"] }
    var passwordTextField: XCUIElement { return app.webViews.secureTextFields.element }
    var submitButton: XCUIElement { return app.webViews.buttons["Submit"] }

    init(app: XCUIApplication) {
        self.app = app
    }

}
