//
//  XenditIntegrationTestsV3.swift
//  Xendit
//
//  Created by Ahmad Alfhajri on 16/10/2024.
//

import XCTest
@testable import Xendit

class XenditIntegrationTestsV3: XCTestCase {
    
    //Empty VC
    private let viewController = UIViewController()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        Xendit.publishableKey = "xnd_public_development_D8wJuWpOY15JvjJyUNfCdDUTRYKGp8CSM3W0ST4d0N4CsugKyoGEIx6b84j1D7Pg"
        Xendit.setLogLevel(.verbose)
    }
    //TODO: Need to setup CARD
    
    
}

private extension XenditIntegrationTestsV3 {
    func getCardData(
        cardNumber: String = TestCard.validCard,
        cardExpMonth: String = "12",
        cardExpYear: String = "2030",
        cardCvn: String? = nil
    ) -> XenditCardData {
        let cardData = XenditCardData.init(
            cardNumber: cardNumber,
            cardExpMonth: cardExpMonth,
            cardExpYear: cardExpYear
        )
        
        //Should it be here or not?
        if let cardCvn = cardCvn {
            cardData.cardCvn = cardCvn
        }
        
        return cardData
    }
}

//MARK: - Helper
private extension XenditIntegrationTestsV3 {
    enum Status: String {
        case success = "SUCCESS"
        case failed = "FAILED"
    }
    
    static func setDescription(for status: Status, description: String) -> String {
        return "\(status.rawValue): \(description)"
    }
}


// MARK: - Test Constants
private extension XenditIntegrationTestsV3 {
    enum TestConstants {
        static let defaultTimeout: TimeInterval = 200
        static let defaultAmount: NSNumber = 0
        static let defaultAmount3DS: NSNumber = 10000
        static let defaultCurrency = "IDR"
        
        enum CardData {
            static let validCardNumber = "4000000000001091"
            static let invalidCardNumber = "4000000000001099"
            static let validExpMonth = "12"
            static let invalidExpMonth = "13"
            static let validExpYear = "2030"
            static let invalidExpYear = "2001"
            static let validCVN = "123"
            static let invalidCVN = "1234"
        }
        
        enum ErrorMessages {
            static let invalidExpirationDate = "Card expiration date is invalid"
            static let invalidCardNumber = "Card number is invalid"
            static let invalidCVN = "Card CVN is invalid for this card type"
            static let authenticationRequired = "You do not have permission to skip authentication, please contact our support to give you permission"
            static let unsupportedCurrency = "Invalid currency, your business cannot process transaction with this currency"
            static let invalidCurrency = "Currency ZZZ is invalid"
            static let emptyCardCVN = "\"cvn\" is not allowed to be empty"
            static let missingLastName = "\"card_holder_first_name\" missing required peer \"card_holder_last_name\""
            static let missingFirstName = "\"card_holder_last_name\" missing required peer \"card_holder_first_name\""
            static let phoneRequiresFirstName = "\"card_holder_phone_number\" missing required peer \"card_holder_first_name\""
            static let amountRequired = "\"amount\" is required"
            static let midNotFound = "Mid settings not found for this mid label"
        }
        
        enum CardHolder {
            static let firstName = "John"
            static let lastName = "Doe"
            static let email = "johndoe@gmail.com"
            static let phoneNumber = "+12345678"
        }
        
        enum BillingDetails {
            static let address = "California, random st, 14045"
            static let mobileNumber = "+12345678"
            static let email = "john.doe@gmail.com"
        }
        
        enum TokenStatus {
            static let verified = "VERIFIED"
            static let inReview = "IN_REVIEW"
        }
        
        enum Description {
            static let createMultipleUseToken = "Create multiple use token"
        }
    }
    
    enum TokenType {
        case singleUse
        case multipleUse
        
        var isSingleUse: Bool {
            switch self {
            case .singleUse: return true
            case .multipleUse: return false
            }
        }
    }
    
    enum ErrorCode: String {
        case validationError = "VALIDATION_ERROR"
        case authenticationRequired = "AUTHENTICATION_REQUIRED_ERROR"
        case mismatchCurrency = "MISMATCH_CURRENCY_ERROR"
        case invalidCurrency = "INVALID_CURRENCY_ERROR"
        case apiValidation = "API_VALIDATION_ERROR"
        case midNotFound = "MID_NOT_FOUND_ERROR"
    }
    
    struct CardHolderData {
        let firstName: String?
        let lastName: String?
        let email: String?
        let phoneNumber: String?
    }
    
    enum ExpectedResult {
        case success(status: String)
        case error(code: ErrorCode, message: String)
    }
    
    struct BillingDetails {
        let givenNames: String
        let middleName: String?
        let surname: String
        let email: String
        let mobileNumber: String
        let address: Address
    }
    
    struct Address {
        let country: String?
        let streetLine1: String?
        let streetLine2: String?
        let city: String?
        let provinceState: String?
        let postalCode: String?
        let category: String?
        
        func toXenditAddress() -> XenditAddress {
            let address = XenditAddress()
            address.country = country
            address.streetLine1 = streetLine1
            address.streetLine2 = streetLine2
            address.city = city
            address.provinceState = provinceState
            address.postalCode = postalCode
            address.category = category
            
            return address
        }
    }
    
    struct TokenRequest {
        let cardNumber: String
        let cardExpMonth: String
        let cardExpYear: String
        let cardCVN: String?
        let amount: NSNumber?
        let currency: String?
        let shouldAuthenticate: Bool
        let cardHolderData: CardHolderData?
        let midLabel: String?
        let billingDetails: BillingDetails?
        let tokenType: TokenType
        let expectedResult: ExpectedResult
        let completionHandler: ((XenditCCToken?) -> Void)?
        
        
        init(
            cardNumber: String,
            cardExpMonth: String,
            cardExpYear: String,
            cardCVN: String?,
            amount: NSNumber? = TestConstants.defaultAmount,
            currency: String? = nil,
            shouldAuthenticate: Bool = true,
            cardHolderData: CardHolderData? = nil,
            midLabel: String? = nil,
            billingDetails: BillingDetails? = nil,
            tokenType: TokenType = .singleUse,
            expectedResult: ExpectedResult,
            completionHandler: ((XenditCCToken?) -> Void)? = nil
        ) {
            self.cardNumber = cardNumber
            self.cardExpMonth = cardExpMonth
            self.cardExpYear = cardExpYear
            self.cardCVN = cardCVN
            self.amount = amount
            self.currency = currency
            self.shouldAuthenticate = shouldAuthenticate
            self.cardHolderData = cardHolderData
            self.midLabel = midLabel
            self.billingDetails = billingDetails
            self.tokenType = tokenType
            self.expectedResult = expectedResult
            self.completionHandler = completionHandler
        }
    }
    
    struct AuthenticationRequest {
        let tokenId: String
        let amount: NSNumber
        let cardCVN: String?
        let currency: String?
        let cardHolderData: CardHolderData?
        let expectedResult: ExpectedResult
        
        init(
            tokenId: String,
            amount: NSNumber,
            cardCVN: String? = nil,
            currency: String? = nil,
            cardHolderData: CardHolderData? = nil,
            expectedResult: ExpectedResult
        ) {
            self.tokenId = tokenId
            self.amount = amount
            self.cardCVN = cardCVN
            self.currency = currency
            self.cardHolderData = cardHolderData
            self.expectedResult = expectedResult
        }
    }
    
    struct StoreCVNRequest {
        let tokenId: String
        let cardCVN: String
        let expectedResult: ExpectedResult
    }
}

private extension XCTestExpectation {
    static func xenditExpectation(description: String) -> XCTestExpectation {
        Self(description: XenditIntegrationTestsV3.setDescription(for: .success, description: description))
    }
}

// MARK: - Test Helpers
private extension XenditIntegrationTestsV3 {
    func runTokenizationTest(request: TokenRequest, createTokenExpectation: XCTestExpectation) {
        let cardData = getCardData(
            cardNumber: request.cardNumber,
            cardExpMonth: request.cardExpMonth,
            cardExpYear: request.cardExpYear,
            cardCvn: request.cardCVN
        )
        
        if let holderData = request.cardHolderData {
            cardData.cardHolderFirstName = holderData.firstName
            cardData.cardHolderLastName = holderData.lastName
            cardData.cardHolderEmail = holderData.email
            cardData.cardHolderPhoneNumber = holderData.phoneNumber
        }
        
        let tokenizationRequest = XenditTokenizationRequest(
            cardData: cardData,
            isSingleUse: request.tokenType.isSingleUse,
            shouldAuthenticate: request.shouldAuthenticate,
            amount: request.amount,
            currency: request.currency
        )
        
        if let billing = request.billingDetails {
            tokenizationRequest.billingDetails = XenditBillingDetails()
            tokenizationRequest.billingDetails?.givenNames = billing.givenNames
            tokenizationRequest.billingDetails?.middleName = billing.middleName
            tokenizationRequest.billingDetails?.surname = billing.surname
            tokenizationRequest.billingDetails?.email = billing.email
            tokenizationRequest.billingDetails?.mobileNumber = billing.mobileNumber
            tokenizationRequest.billingDetails?.address = billing.address.toXenditAddress()
        }
        
        if let midLabel = request.midLabel {
            tokenizationRequest.midLabel = midLabel
        }
        
        Xendit.createToken(
            fromViewController: viewController,
            tokenizationRequest: tokenizationRequest,
            onBehalfOf: nil) { response, error in
                
                switch request.expectedResult {
                case let .success(status):
                    XCTAssertNil(error)
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.status, status)
                    
                case let .error(code, message):
                    print("error \(error?.errorCode ?? "NIL"): \(error?.message ?? "NIL")")
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error?.errorCode, code.rawValue)
                    XCTAssertEqual(error?.message?.contains(message), true)
                }
                
                request.completionHandler?(response)
                createTokenExpectation.fulfill()
            }
        
        //TODO: check if it is viable method
        //Nil was expected for test that rely on expectation from runTokenizationTest
        if request.completionHandler == nil {
            wait(for: [createTokenExpectation], timeout: TestConstants.defaultTimeout)
        }
    }
    
    func runAuthenticationTest(request: AuthenticationRequest, expectation: XCTestExpectation) {
        let authenticationRequest = XenditAuthenticationRequest(
            tokenId: request.tokenId,
            amount: request.amount,
            currency: request.currency ?? "",
            cardData: nil
        )
        
        // Add CVN if present
        if let cvn = request.cardCVN {
            authenticationRequest.cardCvn = cvn
        }
        
        // Add card holder data if present
        if let holderData = request.cardHolderData {
            authenticationRequest.cardData = XenditCardHolderInformation(
                cardHolderFirstName: holderData.firstName,
                cardHolderLastName: holderData.lastName,
                cardHolderEmail: holderData.email,
                cardHolderPhoneNumber: holderData.phoneNumber
            )
        }
        
        Xendit.createAuthentication(
            fromViewController: viewController,
            authenticationRequest: authenticationRequest,
            onBehalfOf: nil) { response, error in
                switch request.expectedResult {
                case let .success(status):
                    XCTAssertNil(error)
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.status, status)
                    XCTAssertNotNil(response?.id)
                    XCTAssertNotNil(response?.authenticationURL)
                    
                case let .error(code, message):
                    print("error \(message) errorcode \(error?.message ?? "emtpy")")
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error?.errorCode, code.rawValue)
                    XCTAssertEqual(error?.message?.contains(message), true)
                }
                
                expectation.fulfill()
            }
    }
    
    func runStoreCVNTest(request: StoreCVNRequest, expectation: XCTestExpectation) {
        Xendit.storeCVN(
            fromViewController: viewController,
            storeCVNRequest: .init(tokenId: request.tokenId),
            onBehalfOf: nil
        ) { token, error in
            
            switch request.expectedResult {
            case let .success(status):
                XCTAssertNil(error)
                XCTAssertNotNil(token)
                XCTAssertEqual(token?.status, status)
                
                //                    // Verify response contains expected fields
                //                    XCTAssertNotNil(token?.id)
                //                    XCTAssertNotNil(token?.authenticationId)
                //                    XCTAssertEqual(token?.maskedCardNumber?.contains("400000"), true)
                //
                //                    // Verify card info
                //                    let cardInfo = token?.cardInfo
                //                    XCTAssertEqual(cardInfo?.bank, TestConstants.SuccessResponse.cardInfoPresent["bank"])
                //                    XCTAssertEqual(cardInfo?.country, TestConstants.SuccessResponse.cardInfoPresent["country"])
                //                    XCTAssertEqual(cardInfo?.type, TestConstants.SuccessResponse.cardInfoPresent["type"])
                //                    XCTAssertEqual(cardInfo?.brand, TestConstants.SuccessResponse.cardInfoPresent["brand"])
                //
                //                    // Verify expiration dates are present
                //                    XCTAssertNotNil(cardInfo?.cardExpirationMonth)
                //                    XCTAssertNotNil(cardInfo?.cardExpirationYear)
                
            case let .error(code, message):
                XCTAssertNotNil(error)
                XCTAssertEqual(error?.errorCode, code.rawValue)
                XCTAssertEqual(error?.message?.contains(message), true)
            }
            
            expectation.fulfill()
        }
    }
    
    func validateError(error: XenditError?, expectedMessage: String) {
        XCTAssertNotNil(error, XenditIntegrationTestsV3.setDescription(for: .failed, description: "error should not be nil"))
        XCTAssertEqual(
            error?.errorCode,
            "VALIDATION_ERROR",
            XenditIntegrationTestsV3.setDescription(for: .failed, description: "error code should be VALIDATION_ERROR")
        )
        XCTAssertEqual(
            error?.message,
            expectedMessage,
            XenditIntegrationTestsV3.setDescription(for: .failed, description: "error message should match expected message")
        )
    }
}

// MARK: - Test Cases
extension XenditIntegrationTestsV3 {
    // MARK: - CREATE SINGLE USE TOKEN
    func testCreateSingleUseTokenWithInvalidCardExpiryMonth() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.invalidExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            expectedResult: .error(
                code: .validationError,
                message: TestConstants.ErrorMessages.invalidExpirationDate
            )
        )
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with invalid card expiry month")
        )
    }
    
    func testCreateSingleUseTokenWithInvalidCardExpiryYear() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.invalidExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            expectedResult: .error(
                code: .validationError,
                message: TestConstants.ErrorMessages.invalidExpirationDate
            )
        )
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with invalid card expiry year")
        )
    }
    
    //When put to validCard Number didn't manage to finish the flow because it redirect Webview
    func testCreateSingleUseTokenWithInvalidCardNumber() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.invalidCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            expectedResult: .error(
                code: .validationError,
                message: TestConstants.ErrorMessages.invalidCardNumber
            )
        )
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with invalid card number")
        )
        
    }
    
    func testCreateSingleUseTokenWithInvalidCardCVN() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.invalidCVN,
            expectedResult: .error(
                code: .validationError,
                message: TestConstants.ErrorMessages.invalidCVN
            )
        )
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with invalid card CVN")
        )
        
    }
    
    // Test case for creating token without 3DS (Row 10)
    func testCreateSingleUseTokenWithout3DS() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            amount: TestConstants.defaultAmount3DS,
            shouldAuthenticate: true,
            expectedResult: .success(status: TestConstants.TokenStatus.inReview)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token without 3DS")
        )
        
    }
    
    // Test case for creating token with 3DS disabled (Row 11)
    func testCreateSingleUseTokenWith3DSDisabled() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            amount: TestConstants.defaultAmount3DS,
            shouldAuthenticate: false,
            expectedResult: .error(
                code: .authenticationRequired,
                message: TestConstants.ErrorMessages.authenticationRequired
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with 3DS disabled")
        )
        
    }
    
    // Test case for creating token with supported currency (Row 12)
    func testCreateSingleUseTokenWithSupportedCurrency() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            currency: TestConstants.defaultCurrency,
            expectedResult: .success(status: TestConstants.TokenStatus.inReview)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with supported currency")
        )
        
    }
    
    // Test case for creating token with unsupported currency (Row 13)
    func testCreateSingleUseTokenWithUnsupportedCurrency() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            amount: TestConstants.defaultAmount3DS,
            currency: "GBP",
            expectedResult: .error(
                code: .mismatchCurrency,
                message: TestConstants.ErrorMessages.unsupportedCurrency
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with unsupported currency")
        )
        
    }
    
    // Test case for creating token with invalid currency (Row 14)
    func testCreateSingleUseTokenWithInvalidCurrency() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            currency: "ZZZ",
            expectedResult: .error(
                code: .invalidCurrency,
                message: TestConstants.ErrorMessages.invalidCurrency
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with invalid currency")
        )
        
    }
    
    // Test case for creating token without CVN (Row 15)
    func testCreateSingleUseTokenWithoutCVN() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: nil,
            amount: TestConstants.defaultAmount3DS,
            expectedResult: .error(
                code: .apiValidation,
                message: TestConstants.ErrorMessages.emptyCardCVN
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token without CVN")
        )
        
    }
    
    // Test case for creating token with complete card holder data (Row 16)
    func testCreateSingleUseTokenWithCompleteCardHolderData() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            cardHolderData: CardHolderData(
                firstName: TestConstants.CardHolder.firstName,
                lastName: TestConstants.CardHolder.lastName,
                email: TestConstants.CardHolder.email,
                phoneNumber: TestConstants.CardHolder.phoneNumber
            ),
            expectedResult: .success(status: TestConstants.TokenStatus.inReview)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with complete card holder data")
        )
        
    }
    
    // Test case for creating token with only first name (Row 17)
    func testCreateSingleUseTokenWithOnlyFirstName() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            cardHolderData: CardHolderData(
                firstName: TestConstants.CardHolder.firstName,
                lastName: nil,
                email: nil,
                phoneNumber: nil
            ),
            expectedResult: .error(
                code: .apiValidation,
                message: TestConstants.ErrorMessages.missingLastName
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with only first name")
        )
        
    }
    
    // Test case for creating token with only last name (Row 18)
    func testCreateSingleUseTokenWithOnlyLastName() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            cardHolderData: CardHolderData(
                firstName: nil,
                lastName: TestConstants.CardHolder.lastName,
                email: nil,
                phoneNumber: nil
            ),
            expectedResult: .error(
                code: .apiValidation,
                message: TestConstants.ErrorMessages.missingFirstName
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with only last name")
        )
        
    }
    
    // Test case for creating token with only email (Row 19)
    func testCreateSingleUseTokenWithOnlyEmail() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            cardHolderData: CardHolderData(
                firstName: nil,
                lastName: nil,
                email: TestConstants.CardHolder.email, // Email is a legacy parameter, allowed alone
                phoneNumber: nil
            ),
            expectedResult: .success(status: TestConstants.TokenStatus.inReview)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with only email")
        )
        
    }
    
    // Test case for creating token with only phone number (Row 20)
    func testCreateSingleUseTokenWithOnlyPhoneNumber() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            cardHolderData: CardHolderData(
                firstName: nil,
                lastName: nil,
                email: nil,
                phoneNumber: TestConstants.CardHolder.phoneNumber
            ),
            expectedResult: .error(
                code: .apiValidation,
                message: TestConstants.ErrorMessages.phoneRequiresFirstName
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with only phone number")
        )
        
    }
    
    // Test case for creating token without amount (Row 21)
    func testCreateSingleUseTokenWithoutAmount() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            amount: nil,
            expectedResult: .error(
                code: .apiValidation,
                message: TestConstants.ErrorMessages.amountRequired
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token without amount")
        )
        
    }
    
    // Test case for creating token with midLabel (Row 22)
    func testCreateSingleUseTokenWithMidLabel() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            midLabel: "RANDOM",
            expectedResult: .error(
                code: .midNotFound,
                message: TestConstants.ErrorMessages.midNotFound
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with midLabel")
        )
        
    }
    
    // Test case for creating token with billing details (Row 23)
    func testCreateSingleUseTokenWithBillingDetails() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            billingDetails: BillingDetails(
                givenNames: "John",
                middleName: "Hob",
                surname: "Doe",
                email: "john.doe@gmail.com",
                mobileNumber: "+12345678",
                address: .init(
                    country: nil,
                    streetLine1: "random st",
                    streetLine2: nil,
                    city: "California",
                    provinceState: nil,
                    postalCode: "14045",
                    category: nil
                )
            ),
            expectedResult: .success(status: TestConstants.TokenStatus.inReview)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create token with billing details")
        )
        
    }

    //MARK: - CREATE AUTHENTICATION : SINGLE USE TOKEN

    // Test case for creating authentication with single use token (Row 27)
    func testCreateAuthenticationWithSingleUseToken() {
        let createTokenExpectation = expectation(description: "Create single use token")
        let createAuthenticationExpectation = expectation(description: "Create authentication")
        
        // First create single use token
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false, // PRE-REQUISITE: shouldAuthenticate: false
            tokenType: .singleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                // Then create authentication
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(request: tokenRequest, createTokenExpectation: createTokenExpectation)
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with CVN (Row 28-29)
    func testCreateAuthenticationWithSingleUseTokenAndCVN() {
        let createTokenExpectation = expectation(description: "Create single use token")
        let createAuthenticationExpectation = expectation(description: "Create authentication with CVN")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false,
            tokenType: .singleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: "123", // Adding CVN to authentication
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(request: tokenRequest, createTokenExpectation: createTokenExpectation)
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with supported currency (Row 29)
    func testCreateAuthenticationWithSingleUseTokenAndCurrency() {
        let createTokenExpectation = expectation(description: "Create single use token")
        let createAuthenticationExpectation = expectation(description: "Create authentication with currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false,
            tokenType: .singleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    currency: TestConstants.defaultCurrency,
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(request: tokenRequest, createTokenExpectation: createTokenExpectation)
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with unsupported currency (Row 30)
    func testCreateAuthenticationWithSingleUseTokenAndUnsupportedCurrency() {
        let createTokenExpectation = expectation(description: "Create single use token")
        let createAuthenticationExpectation = expectation(description: "Create authentication with unsupported currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false,
            tokenType: .singleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    currency: "GBP",
                    expectedResult: .error(
                        code: .mismatchCurrency,
                        message: TestConstants.ErrorMessages.unsupportedCurrency
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(request: tokenRequest, createTokenExpectation: createTokenExpectation)
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with invalid currency (Row 31)
    func testCreateAuthenticationWithSingleUseTokenAndInvalidCurrency() {
        let createTokenExpectation = expectation(description: "Create single use token")
        let createAuthenticationExpectation = expectation(description: "Create authentication with invalid currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false,
            tokenType: .singleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    currency: "ZZZ",
                    expectedResult: .error(
                        code: .invalidCurrency,
                        message: TestConstants.ErrorMessages.invalidCurrency
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(request: tokenRequest, createTokenExpectation: createTokenExpectation)
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    //MARK: - CREATE MULTIPLE USE TOKEN
    // Test case for creating multiple use token without CVN (Row 24)
    func testCreateMultipleUseTokenWithoutCVN() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: nil,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create multiple use token without CVN")
        )
        
    }
    
    // Test case for creating multiple use token with CVN (Row 25)
    func testCreateMultipleUseTokenWithCVN() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified)
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create multiple use token with CVN")
        )
        
    }
    
    // Test case for creating multiple use token with midLabel (Row 26)
    func testCreateMultipleUseTokenWithMidLabel() {
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            midLabel: "RANDOM",
            tokenType: .multipleUse,
            expectedResult: .error(
                code: .midNotFound,
                message: TestConstants.ErrorMessages.midNotFound
            )
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create multiple use token with midLabel")
        )
        
    }
    //MARK: - CREATE AUTHENTICATION : MULTIPLE USE TOKEN
    // Test case for creating authentication with multiple use token (Row 32)
    func testCreateAuthenticationWithMultipleUseToken() {
        let createAuthenticationExpectation = expectation(description: "Create authentication")
        
        // First create multiple use token
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                // Then create authentication
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    currency: TestConstants.defaultCurrency, //Different from Doc: Added currency
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with CVN (Row 33)
    func testCreateAuthenticationWithCVN() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with CVN")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency, //Different from Doc: Added currency
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with currency (Row 34)
    func testCreateAuthenticationWithCurrency() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with unsupported currency (Row 35)
    func testCreateAuthenticationWithUnsupportedCurrency() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with unsupported currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                //TODO: Error lain pulok
                //[xendit] data: {"error_code":"MISMATCH_CURRENCY_ERROR","message":"Mid settings not found for this currency"}

                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount3DS,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: "GBP",
                    expectedResult: .error(
                        code: .mismatchCurrency,
                        message: TestConstants.ErrorMessages.unsupportedCurrency
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with invalid currency (Row 36)
    func testCreateAuthenticationWithInvalidCurrency() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with invalid currency")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: "ZZZ",
                    expectedResult: .error(
                        code: .invalidCurrency,
                        message: TestConstants.ErrorMessages.invalidCurrency
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with complete card holder data (Row 37)
    func testCreateAuthenticationWithCompleteCardHolderData() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with complete card holder data")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    cardHolderData: CardHolderData(
                        firstName: TestConstants.CardHolder.firstName,
                        lastName: TestConstants.CardHolder.lastName,
                        email: TestConstants.CardHolder.email,
                        phoneNumber: TestConstants.CardHolder.phoneNumber
                    ),
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with only first name (Row 38)
    func testCreateAuthenticationWithOnlyFirstName() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with only first name")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                //TODO: Keno ado currency
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    cardHolderData: CardHolderData(
                        firstName: TestConstants.CardHolder.firstName,
                        lastName: nil,
                        email: nil,
                        phoneNumber: nil
                    ),
                    expectedResult: .error(
                        code: .apiValidation,
                        message: TestConstants.ErrorMessages.missingLastName
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with only last name (Row 39)
    func testCreateAuthenticationWithOnlyLastName() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with only last name")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    cardHolderData: CardHolderData(
                        firstName: nil,
                        lastName: TestConstants.CardHolder.lastName,
                        email: nil,
                        phoneNumber: nil
                    ),
                    expectedResult: .error(
                        code: .apiValidation,
                        message: TestConstants.ErrorMessages.missingFirstName
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with only email (Row 40)
    func testCreateAuthenticationWithOnlyEmail() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with only email")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    cardHolderData: CardHolderData(
                        firstName: nil,
                        lastName: nil,
                        email: TestConstants.CardHolder.email,
                        phoneNumber: nil
                    ),
                    expectedResult: .success(status: TestConstants.TokenStatus.inReview)
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    // Test case for creating authentication with only phone number (Row 41)
    func testCreateAuthenticationWithOnlyPhoneNumber() {
        let createAuthenticationExpectation = expectation(description: "Create authentication with only phone number")
        
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                let authenticationRequest = AuthenticationRequest(
                    tokenId: tokenId,
                    amount: TestConstants.defaultAmount,
                    cardCVN: TestConstants.CardData.validCVN,
                    currency: TestConstants.defaultCurrency,
                    cardHolderData: CardHolderData(
                        firstName: nil,
                        lastName: nil,
                        email: nil,
                        phoneNumber: TestConstants.CardHolder.phoneNumber
                    ),
                    expectedResult: .error(
                        code: .apiValidation,
                        message: TestConstants.ErrorMessages.phoneRequiresFirstName
                    )
                )
                
                self.runAuthenticationTest(request: authenticationRequest, expectation: createAuthenticationExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: TestConstants.Description.createMultipleUseToken)
        )
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
    
    //MARK: - STORE CVN
    // Test case for storing CVN with multiple use token (Row 42)
    func testStoreCVNWithMultipleUseToken() {
        let storeCVNExpectation = expectation(description: XenditIntegrationTestsV3.setDescription(for: .success, description: "Store CVN for multiple use token"))
        
        // First create a multiple use token
        let tokenRequest = TokenRequest(
            cardNumber: TestConstants.CardData.validCardNumber,
            cardExpMonth: TestConstants.CardData.validExpMonth,
            cardExpYear: TestConstants.CardData.validExpYear,
            cardCVN: TestConstants.CardData.validCVN,
            shouldAuthenticate: false,
            tokenType: .multipleUse,
            expectedResult: .success(status: TestConstants.TokenStatus.verified),
            completionHandler: { [weak self] token in
                guard let self = self,
                      let tokenId = token?.id else {
                    XCTFail("Failed to get token ID")
                    return
                }
                
                // Then store CVN
                let storeCVNRequest = StoreCVNRequest(
                    tokenId: tokenId,
                    cardCVN: TestConstants.CardData.validCVN,
                    expectedResult: .success(status: TestConstants.TokenStatus.verified)
                )
                
                self.runStoreCVNTest(request: storeCVNRequest, expectation: storeCVNExpectation)
            }
        )
        
        runTokenizationTest(
            request: tokenRequest,
            createTokenExpectation: .xenditExpectation(description: "Create multiple use token for storing CVN")
        )
        
        
        waitForExpectations(timeout: TestConstants.defaultTimeout)
    }
}
