//
//  LogSanitizerTests.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 01/11/2018.
//

import XCTest
@testable import XenditSDKSwift


class LogSanitizerTest: XCTestCase {
    let input: [String: Any] = [
        "keyId": "07GOabcdefghijklmnopqrstuvwxqgTE",
        "cardExpirationYear": 2020,
        "cardNumber": "4000000000000002",
        "cardExpirationMonth": "16",
        "cardType": "001",
    ]
    let output = [
        "keyId": "07GO************************qgTE",
        "cardExpirationYear": "****",
        "cardNumber": "4000********0002",
        "cardExpirationMonth": "**",
        "cardType": "001",
    ]

    let sut = LogSanitizer()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testNonJsonBody() {
        let res = sut.sanitizeRequestBody(["key": NSObject()]) as? String
        XCTAssertNotNil(res)
        XCTAssertEqual(res, "<invalid JSON>")
    }

    func testDictionary() {
        let res = sut.sanitizeRequestBody(input) as? [String: String]
        XCTAssertEqual(res, output)
    }

    func testNestedDictionary() {
        let res = sut.sanitizeRequestBody([
            "someOtherKey": 1,
            "cardInfo": input
        ]) as? [String: Any]

        XCTAssertEqual(res?["someOtherKey"] as? Int, 1)
        XCTAssertEqual(res?["cardInfo"] as? [String: String], output)
    }

    func testArray() {
        let res = sut.sanitizeRequestBody([
            "key": [
                ["some": "dict"],
                input
            ]
        ]) as? [String: Any]

        let nested = res?["key"] as? [Any]

        XCTAssertEqual(nested?.count, 2)
        XCTAssertEqual(nested?[0] as? [String: String], ["some": "dict"])
        XCTAssertEqual(nested?[1] as? [String: String], output)
    }
}
