//
//  XenditExampleUITests.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 24/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest

class XenditExampleUITests: BaseTestCase {
    enum TestCards {
        static let validVisa = "4111111111111111"
        static let validVisa3ds = "4000000000000002"
        static let refusedVisa = "4111113333333333"

        static let password3ds = "1234"
    }

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launch()
    }

    func testCreateToken() {

        homeScreen.createTokenButton.tap()

        expectScreenTitle(createTokenScreen.title)
        createTokenScreen.cardNumberTextField.clearAndEnterText(TestCards.validVisa)
        createTokenScreen.createTokenButton.tap()

        waitForElementToAppear(createTokenScreen.successAlert, timeout: 60)
        let text = createTokenScreen.successAlert.alertMessage
        XCTAssert(text.hasPrefix("TokenID - "))
        XCTAssert(text.contains("Status - VERIFIED"))

        createTokenScreen.successAlert.buttons["OK"].tap()
        navBackButton.tap()
    }

    func testCreateToken3DS() {
        homeScreen.createTokenButton.tap()

        expectScreenTitle(createTokenScreen.title)
        createTokenScreen.cardNumberTextField.clearAndEnterText(TestCards.validVisa3ds)
        createTokenScreen.createTokenButton.tap()


        waitForElementToAppear(webAuthenticationScreen.titleLabel, timeout: 30)
        webAuthenticationScreen.passwordTextField.tap()
        webAuthenticationScreen.passwordTextField.typeText(TestCards.password3ds)
        webAuthenticationScreen.submitButton.tap()

        waitForElementToAppear(createTokenScreen.successAlert, timeout: 60)
        let text = createTokenScreen.successAlert.alertMessage
        XCTAssert(text.hasPrefix("TokenID - "))
        XCTAssert(text.contains("Status - VERIFIED"))
    }
}
