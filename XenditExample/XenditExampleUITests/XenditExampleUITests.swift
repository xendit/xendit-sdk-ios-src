//
//  XenditExampleUITests.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 24/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest

class XenditExampleUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testExample() {
        let app = XCUIApplication()
        app.launch()
    }
}
