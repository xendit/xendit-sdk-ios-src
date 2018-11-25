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
    var authenticationStub: AuthenticationProviderStub!

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
        authenticationStub = AuthenticationProviderStub()
        Xendit.authenticationProvider = authenticationStub
        http = HTTPStub()
    }

    override func tearDown() {
        Xendit.authenticationProvider = AuthenticationProvider()
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

    // MARK: - Test createAuthentication
    /**
     * Sends Xendit.createAuthentication request, asynchronously waits for the response,
     * ensures that completion callback is called on the main thread,
     * then runs assertions block (passing response objects there).
     * - Parameter authenticationResponse: the server response for "/credit_card_tokens/:tokenId/authentications" endpoint you want to test
     * - Parameter webAuthenticationResponse: the `AuthenticationWebViewController` stub response you want to test
     * - Parameter assertions: this callback will be called on `Xendit.createAuthentication` completion and you can run assertions on authentication result.
     */
    private func doTestCreateAuthenticationWhen(
        authenticationResponse: HTTPStub.ResponseFixture,
        webAuthenticationResponse: (XenditAuthentication?, XenditError?),
        file: StaticString = #file, line: UInt = #line,
        assertions: @escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void
    ) {
        let tokenId = "some_token"

        http.failOnUnexpectedRequest()
        http.respond(.authentication(token: tokenId), fixture: authenticationResponse)
        authenticationStub.stubResponse = webAuthenticationResponse

        let expect = expectation(description: "Create authentication callback")
        Xendit.createAuthentication(fromViewController: UIViewController(), tokenId: tokenId, amount: 1000) { authentication, error in
            // Ensure callback is called on the main thread
            XCTAssertTrue(Thread.isMainThread, "Callback is called on background thread", file: file, line: line)
            assertions(authentication, error)
            expect.fulfill()
        }
        xenWait(for: expect, timeout: 1, file: file, line: line)
    }

    func testCreateAuthentication() {
        // Test `createAuthentication` success workflow
        let webAuthResponse = XenditAuthentication(id: "some_authentication_id", status: "VERIFIED", authenticationURL: nil)

        doTestCreateAuthenticationWhen(authenticationResponse: .authenticationSuccess, webAuthenticationResponse: (webAuthResponse, nil)) { authentication, error in
            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(authentication, "authentication should not be nil")
            XCTAssertEqual(authentication?.id, webAuthResponse.id)
            XCTAssertEqual(authentication?.status, webAuthResponse.status)
            XCTAssertNil(authentication?.authenticationURL)
        }
    }

    func testCreateAuthentication_tokenExpired() {
        // The endpoint returned success response, but the token is expired
        doTestCreateAuthenticationWhen(authenticationResponse: .authenticationTokenExpired, webAuthenticationResponse: (nil, nil)) { authentication, error in
            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(authentication, "authentication should not be nil")
            XCTAssertEqual(authentication?.id, "5bf6a29ac26d775e6c2481bd")
            XCTAssertEqual(authentication?.status, "TOKEN_EXPIRED")
            XCTAssertNil(authentication?.authenticationURL)
        }
    }

    func testCreateAuthentication_webAuthenticationError() {
        // The endpoint returned success response, but the web authentication failed
        let webAuthError = XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now")

        doTestCreateAuthenticationWhen(authenticationResponse: .authenticationSuccess, webAuthenticationResponse: (nil, webAuthError)) { authentication, error in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, webAuthError.errorCode)
            XCTAssertEqual(error?.message, webAuthError.message)
            XCTAssertNil(authentication)
        }
    }

    func testCreateAuthentication_badRequest() {
        // The endpoint returned "bad request" response with a valid JSON error object
        doTestCreateAuthenticationWhen(authenticationResponse: .badRequest, webAuthenticationResponse: (nil, nil)) { authentication, error in
            XCTAssertNil(authentication, "authentication should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "INVALID_API_KEY")
        }
    }

    func testCreateAuthentication_htmlResponse() {
        // The endpoint responded with some unexpected HTML response
        doTestCreateAuthenticationWhen(authenticationResponse: .htmlResponse, webAuthenticationResponse: (nil, nil)) { authentication, error in
            XCTAssertNil(authentication, "authentication should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
        }
    }

    func testCreateAuthentication_corruptedJsonResponse() {
        // the endpoint responded with corrupted JSON response
        doTestCreateAuthenticationWhen(authenticationResponse: .corruptedJson, webAuthenticationResponse: (nil, nil)) { authentication, error in
            XCTAssertNil(authentication, "authentication should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
        }
    }

    func testCreateAuthentication_networkError() {
        // the request failed due to a network error
        doTestCreateAuthenticationWhen(authenticationResponse: .networkError, webAuthenticationResponse: (nil, nil)) { authentication, error in
            XCTAssertNil(authentication, "authentication should be nil")
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertEqual(error?.errorCode, "SERVER_ERROR")
        }
    }
}
