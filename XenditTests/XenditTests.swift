//
//  XenditTests.swift
//  XenditTests
//
//  Created by Maxim Bolotov on 3/15/17.
//
//

import XCTest
@testable import Xendit

class XenditTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: Test create token
    
    func testCreateToken() {
        let expect = expectation(description: "create token")

        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
        let cardData = CardData()
        cardData.cardNumber = "4000000000000002"
        cardData.cardExpYear = "2017"
        cardData.cardExpMonth = "12"
        cardData.cardCvn = "123"
        cardData.amount = 1231
        
        let viewController = UIViewController()
        
        Xendit.createToken(fromViewController: viewController, cardData: cardData) { (token, error) in
            XCTAssertNotNil(token, "token should not be nil")
            XCTAssertNil(error, "error should be nil")
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
        cardData.cardNumber = "4000000000000002"
        cardData.cardExpYear = "2017"
        cardData.cardExpMonth = "10"
        cardData.cardCvn = "123"
        
        let viewController = UIViewController()
        
        Xendit.createToken(fromViewController: viewController, cardData: cardData) { (token, error) in
            XCTAssertNil(token, "token should be nil")
            XCTAssertNotNil(error, "error should not be nil")
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
        
        Xendit.createAuthentication(fromViewController: viewController, tokenId: "0138172342720002", amount: 1231, cardCVN: "123") { (token, error) in
            XCTAssertNotNil(token, "token should not be nil")
            XCTAssertNil(error, "error should be nil")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 150) { error in
            XCTAssertNil(error, "Oh, we got timeout")
        }
    }
    
}
