//
//  XenditTests.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 23/11/2018.
//

import XCTest
@testable import Xendit


class XenditTests: XCTestCase {
    var http: HTTPStub!

    lazy var cardData: CardData = {
        $0.cardNumber = TestCard.validCardNo3ds
        $0.cardExpYear = "2027"
        $0.cardExpMonth = "12"
        $0.cardCvn = "123"
        $0.amount = 1231
        return $0
    }(CardData())

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
        http = HTTPStub()
    }

    override func tearDown() {
        http.tearDown()
    }

    // MARK: - Helper functions
    /**
     * Version of `wait(for:, timeout:)` that accepts `file` and `line` arguments.
     */
    private func xenWait(for expectation: XCTestExpectation, timeout seconds: TimeInterval, file: StaticString = #file, line: UInt = #line) {
        let result = XCTWaiter.wait(for: [expectation], timeout: seconds)
        switch result {
        case .completed: break
        case .incorrectOrder: XCTFail("\(expectation.expectationDescription) not called: incorrectOrder", file: file, line: line)
        case .interrupted: XCTFail("\(expectation.expectationDescription) not called: interrupted", file: file, line: line)
        case .invertedFulfillment: XCTFail("\(expectation.expectationDescription) not called: invertedFulfillment", file: file, line: line)
        case .timedOut: XCTFail("\(expectation.expectationDescription) not called: timeOut", file: file, line: line)
        }
    }

    // MARK: - Test createToken

    /**
     * Sends Xendit.createToken request, asynchronously waits for the response,
     * ensures that completion callback is called on the main thread,
     * then runs assertions block (passing response objects there).
     * - Parameter assertions: this callback will be called on `Xendit.createToken` completion and you can run assertions on token creation result.
     */
    private func doTestCreateToken(file: StaticString = #file, line: UInt = #line, assertions: @escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        let expect = expectation(description: "Create token callback")
        Xendit.createToken(fromViewController: UIViewController(), cardData: cardData) { token, error in
            // Ensure callback is called on the main thread
            XCTAssertTrue(Thread.isMainThread, "Callback is called on background thread", file: file, line: line)
            assertions(token, error)
            expect.fulfill()
        }
        xenWait(for: expect, timeout: 1, file: file, line: line)
    }

    func testCreateToken() {
        // Test `createToken` success workflow
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .tokenizeCardSuccess)
        http.respond(.createCreditCard, fixture: .createCreditCardSuccess)

        doTestCreateToken { token, error in
            XCTAssertNil(error, "error should not be nil")
            XCTAssertNotNil(token, "token should be nil")
            XCTAssertEqual(token?.id, "5bf7e566399c7527e8e9fa5a")
            XCTAssertEqual(token?.authenticationId, "5bf7e566399c7527e8e9fa5b")
            XCTAssertEqual(token?.status, "VERIFIED")
            XCTAssertEqual(token?.maskedCardNumber, "520000XXXXXX0056")
        }
    }

    // MARK: .tokenCredentials different responses
    func testCreateToken_tokenCredentials_badRequest() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .badRequest)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "INVALID_API_KEY")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenCredentials_htmlResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .htmlResponse)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenCredentials_corruptedJsonResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .corruptedJson)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenCredentials_networkError() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .networkError)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    // MARK: .tokenizeCard different responses
    func testCreateToken_tokenizeCard_badRequest() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .badRequest)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenizeCard_htmlResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .htmlResponse)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenizeCard_corruptedJsonResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .corruptedJson)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_tokenizeCard_networkError() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .networkError)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    // MARK: .createCreditCard different responses
    func testCreateToken_createCreditCard_badRequest() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .tokenizeCardSuccess)
        http.respond(.createCreditCard, fixture: .badRequest)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "INVALID_API_KEY")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_createCreditCard_htmlResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .tokenizeCardSuccess)
        http.respond(.createCreditCard, fixture: .htmlResponse)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_createCreditCard_corruptedJsonResponse() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .tokenizeCardSuccess)
        http.respond(.createCreditCard, fixture: .corruptedJson)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }

    func testCreateToken_createCreditCard_networkError() {
        http.failOnUnexpectedRequest()
        http.respond(.tokenCredentials, fixture: .tokenCredentialsSuccess)
        http.respond(.tokenizeCard, fixture: .tokenizeCardSuccess)
        http.respond(.createCreditCard, fixture: .networkError)

        doTestCreateToken { token, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
            XCTAssertNil(token, "token should be nil")
        }
    }
}
