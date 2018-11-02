//
//  CreteTokenUITests.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 24/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest

class CreateTokenUITests: BaseTestCase {
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

        createTokenScreen.successAlert.buttons["OK"].tap()
        navBackButton.tap()
    }

    func testCreateToken3DS_CancelAuth() {
        homeScreen.createTokenButton.tap()

        expectScreenTitle(createTokenScreen.title)
        createTokenScreen.cardNumberTextField.clearAndEnterText(TestCards.validVisa3ds)
        createTokenScreen.createTokenButton.tap()


        waitForElementToAppear(webAuthenticationScreen.titleLabel, timeout: 30)
        webAuthenticationScreen.cancelButton.tap()

        let alert = app.alerts["AUTHENTICATION_ERROR"]
        waitForElementToAppear(alert, timeout: 60)
        XCTAssertEqual(alert.alertMessage, "Authentication was cancelled")
        alert.buttons["OK"].tap()

        navBackButton.tap()
    }

    func testCreateToken3DS_FailedAuth() {
        homeScreen.createTokenButton.tap()

        expectScreenTitle(createTokenScreen.title)
        createTokenScreen.cardNumberTextField.clearAndEnterText(TestCards.failed3dsVisa)
        createTokenScreen.createTokenButton.tap()


        waitForElementToAppear(webAuthenticationScreen.titleLabel, timeout: 30)
        webAuthenticationScreen.passwordTextField.tap()
        webAuthenticationScreen.passwordTextField.typeText(TestCards.password3ds)
        webAuthenticationScreen.submitButton.tap()

        waitForElementToAppear(createTokenScreen.successAlert, timeout: 60)
        let text = createTokenScreen.successAlert.alertMessage
        XCTAssert(text.hasPrefix("TokenID - "))
        XCTAssert(text.contains("Status - FAILED"))

        createTokenScreen.successAlert.buttons["OK"].tap()
        navBackButton.tap()
    }

    func testCreateTokenInvalidCard() {
        homeScreen.createTokenButton.tap()

        expectScreenTitle(createTokenScreen.title)
        createTokenScreen.cardNumberTextField.clearAndEnterText(TestCards.refusedVisa)
        createTokenScreen.createTokenButton.tap()

        let alert = app.alerts["TEMPORARY_SERVICE_ERROR"]
        waitForElementToAppear(alert, timeout: 60)
        XCTAssertEqual(alert.alertMessage, "Could not process this transaction due to network errors, try again later")

        alert.buttons["OK"].tap()
        navBackButton.tap()
    }
}
