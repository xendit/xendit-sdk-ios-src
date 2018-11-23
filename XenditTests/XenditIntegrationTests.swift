//
//  XenditIntegrationTests.swift
//  XenditTests
//
//  Created by Maxim Bolotov on 3/15/17.
//
//

import XCTest
@testable import Xendit

class XenditIntegrationTests: XCTestCase {
    enum TestCard {
        static let validCardNo3ds = "5200000000000056"
        static let validCardWith3ds = "4000000000000002"
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    // MARK: Test create token
    
    func testCreateToken() {
        let expect = expectation(description: "create token")

        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
        let cardData = CardData()
        cardData.cardNumber = TestCard.validCardNo3ds
        cardData.cardExpYear = "2027"
        cardData.cardExpMonth = "12"
        cardData.cardCvn = "123"
        cardData.amount = 1231
        
        let viewController = UIViewController()
        
        Xendit.createToken(fromViewController: viewController, cardData: cardData) { (token, error) in
            XCTAssertNil(error, "error should be nil")
            XCTAssertNotNil(token, "token should not be nil")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 200) { error in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func testCreateTokenInvalid() {
        let expect = expectation(description: "create token")
        
        Xendit.publishableKey = "xnd_development_NI+GfOQl1LCvkZQ/eOcbGjCSZ9f3pNh5kCax+R1k+mDV8LKgCwB0hQ=="
        let cardData = CardData()
        cardData.cardNumber = TestCard.validCardNo3ds
        cardData.cardExpYear = "2017"
        cardData.cardExpMonth = "10"
        cardData.cardCvn = "123"
        
        let viewController = UIViewController()
        
        Xendit.createToken(fromViewController: viewController, cardData: cardData) { (token, error) in
            XCTAssertNotNil(error, "error should not be nil")
            XCTAssertNil(token, "token should be nil")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 50) { error in
            XCTAssertNil(error, "Oh, we got timeout")
        }
    }

    func testCreateAuthentication() {
        let expect = expectation(description: "Create Authentication")
        
        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
        let viewController = UIViewController()

        let cardData = CardData()
        cardData.cardNumber = TestCard.validCardNo3ds
        cardData.cardExpYear = "2027"
        cardData.cardExpMonth = "10"
        cardData.cardCvn = "123"
        cardData.isMultipleUse = true

        Xendit.createToken(fromViewController: viewController, cardData: cardData) { token, error in
            XCTAssertNil(error, "error should be nil")
            guard let token = token else {
                XCTFail("Token is nil")
                return
            }
            Xendit.createAuthentication(fromViewController: viewController, tokenId: token.id, amount: 1231) { (token, error) in
                XCTAssertNil(error, "error should be nil")
                XCTAssertNotNil(token, "token should not be nil")
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 150) { error in
            XCTAssertNil(error, "Oh, we got timeout")
        }
    }
}
