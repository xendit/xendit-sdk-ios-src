//
//  BaseUITestCase.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 24/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest

class BaseTestCase: XCTestCase {
    lazy var homeScreen = HomeScreenHelper(app: app)
    lazy var createTokenScreen = CreateTokenScreenHelper(app: app)
    lazy var webAuthenticationScreen = WebAuthenticationScreenHelper(app: app)
    var app: XCUIApplication!

    var navBackButton: XCUIElement { return
        app.navigationBars.children(matching: .button).matching(identifier: "Xendit").element(boundBy: 0) }

    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        XCUIDevice.shared.orientation = .portrait
    }

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5, file: String = #file, line: Int = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }

    func expectScreenTitle(_ title: String, file: String = #file, line: Int = #line) {
        waitForElementToAppear(app.navigationBars[title], file: file, line: line)
    }
}
