//
//  Xendit.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/15/17.
//
//

import Foundation

@objcMembers
@objc(Xendit) open class Xendit: NSObject {
    
    // MARK: - Public methods
    
    // Publishable key
    public static var publishableKey: String?

    // Create token method
    public static func createToken(fromViewController: UIViewController, cardData: CardData!, shouldAuthenticate: Bool, onBehalfOf: String, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        let logPrefix = "createToken:"
        func completionWithLog(error: XenditError) {
            Log.shared.verbose("\(logPrefix) \(error)")
            completion(nil, error)
        }
        Log.shared.verbose("\(logPrefix) start with \(cardData?.description ?? "nil")")
        guard publishableKey != nil else {
            completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        guard cardData.amount != nil && cardData.amount.intValue >= 0 else {
            completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Amount must be a number greater than 0"))
            return
        }
        
        guard cardData.cardNumber != nil && isCardNumberValid(cardNumber: cardData.cardNumber) else {
            completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Card number is invalid"))
            return
        }
        
        guard cardData.cardExpMonth != nil && cardData.cardExpYear != nil && isExpiryValid(cardExpirationMonth: cardData.cardExpMonth, cardExpirationYear: cardData.cardExpYear) else {
            completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Card expiration date is invalid"))
            return
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && isCvnValid(creditCardCVN: cardData.cardCvn!) else {
                completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid"))
                return
            }
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && cardData.cardNumber != nil && isCvnValidForCardType(creditCardCVN: cardData.cardCvn!, cardNumber: cardData.cardNumber!) else {
                completionWithLog(error: XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid for this card type"))
                return
            }
        }
        
        createCreditCardToken(cardData: cardData, shouldAuthenticate: shouldAuthenticate, onBehalfOf: onBehalfOf, completion: { (xenditToken, createTokenError) in
            if cardData.isMultipleUse == true && xenditToken != nil {
                get3DSRecommendation(tokenId: xenditToken!.id, completion: { (threeDSRecommendation, get3DSRecommendationError) in
                    let tokenWith3DSRecommendation = XenditCCToken(token: xenditToken!, should3DS: threeDSRecommendation?.should3DS ?? true)

                    handleCreateCardToken(fromViewController: fromViewController, token: tokenWith3DSRecommendation, error: createTokenError, completion: completion)
                })
            } else {
                handleCreateCardToken(fromViewController: fromViewController, token: xenditToken, error: createTokenError, completion: completion)
            }
        })
    }

    public static func createToken(fromViewController: UIViewController, cardData: CardData!, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        createToken(fromViewController: fromViewController, cardData: cardData, shouldAuthenticate: true, onBehalfOf: "", completion: completion);
    }
    
    public static func createToken(fromViewController: UIViewController, cardData: CardData!, shouldAuthenticate: Bool!, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        createToken(fromViewController: fromViewController, cardData: cardData, shouldAuthenticate: shouldAuthenticate, onBehalfOf: "", completion: completion);
    }
    
    // 3DS Authentication method
    // @param fromViewController The UIViewController from which will be present webview for 3DS Authentication
    // @param tokenId The credit card token id
    // @param amount The transaction amount
    // @param cardCVN The credit card CVN code for create token
    @available(*, deprecated:1.1, message:"cvn no longer used")
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, cardCVN: String, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        self.createAuthentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, completion: completion)
    }
    
    // 3DS Authentication method
    // @param fromViewController The UIViewController from which will be present webview for 3DS Authentication
    // @param tokenId The credit card token id
    // @param amount The transaction amount
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, onBehalfOf: String, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        let authenticationData = AuthenticationData()
        authenticationData.tokenId = tokenId
        authenticationData.amount = amount
        
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)
        url?.appendPathComponent(CREDIT_CARD_PATH)
        url?.appendPathComponent(tokenId)
        url?.appendPathComponent(AUTHENTICATION_PATH)
        let requestBody = prepareCreateAuthenticationBody(authenticationData: authenticationData)
        
        let header: [String: String] = [
            "for-user-id": onBehalfOf
        ]
        
        createAuthenticationRequest(URL: url!, bodyJson: requestBody, extraHeader: header) { (authentication, error) in
            handleCreateAuthentication(fromViewController: fromViewController, authentication: authentication, error: error, completion: completion)
        }
    }
    
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        self.createAuthentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, onBehalfOf: "", completion: completion)
    }


    // Card data validation method
    public static func isCardNumberValid(cardNumber: String) -> Bool {
        return NSRegularExpression.regexCardNumberValidation(cardNumber: cardNumber) &&
                cardNumber.count >= 12 &&
                cardNumber.count <= 19 &&
                getCardType(cardNumber: cardNumber) != CYBCardTypes.UNKNOWN
    }

    // Card expiration date validation method
    public static func isExpiryValid(cardExpirationMonth: String, cardExpirationYear: String) -> Bool {
        let cardExpMonthValid = NSRegularExpression.regexCardNumberValidation(cardNumber: cardExpirationMonth)
        let cardExpYearValid = NSRegularExpression.regexCardNumberValidation(cardNumber: cardExpirationYear)
        if cardExpMonthValid && cardExpYearValid  {
            let expMonthNumber = Int(cardExpirationMonth)!
            let expYearNumber = Int(cardExpirationYear)!
            return expMonthNumber >= 1 && expMonthNumber <= 12 &&
                    expYearNumber >= 2017 && expYearNumber <= 2100
        }
        return false
    }
    
    // Card cvn validation method
    public static func isCvnValid(creditCardCVN: String) -> Bool {
        let cvnLength = creditCardCVN.count
        return NSRegularExpression.regexCardNumberValidation(cardNumber: creditCardCVN) && (cvnLength == 3 || cvnLength == 4)
    }
    
    // Card cvn validation for card type method
    public static func isCvnValidForCardType(creditCardCVN: String, cardNumber: String) -> Bool {
        let cvnLength = creditCardCVN.count
        let isCardTypeAmex = isCardAmex(cardNumber: cardNumber)
        if NSRegularExpression.regexCardNumberValidation(cardNumber: creditCardCVN) {
            return isCardTypeAmex ? cvnLength == 4 : cvnLength == 3
        }
        return false
    }

    // MARK: - Logging
    public static func setLogLevel(_ level: XenditLogLevel?) {
        Log.shared.level = level
    }

    public static func setLogDNALevel(_ level: ISHLogDNALevel?) {
        Log.shared.logDNALevel = level
    }

    // MARK: - Private methods

    internal static var cardAuthenticationProvider: CardAuthenticationProviderProtocol = CardAuthenticationProvider()
    internal static var authenticationProvider: AuthenticationProviderProtocol = AuthenticationProvider()

    // Get Card Type
    internal static func getCardType(cardNumber: String) -> CYBCardTypes {
        if cardNumber.hasPrefix("4") {
            if isCardVisaElectron(cardNumber: cardNumber) {
                return CYBCardTypes.VISA_ELECTRON
            } else {
                return CYBCardTypes.VISA
            }
        } else if isCardAmex(cardNumber: cardNumber) {
            return CYBCardTypes.AMEX
        } else if isCardMastercard(cardNumber: cardNumber) {
            return CYBCardTypes.MASTERCARD
        } else if isCardDiscover(cardNumber: cardNumber) {
            return CYBCardTypes.DISCOVER
        } else if isCardJCB(cardNumber: cardNumber) {
            return CYBCardTypes.JCB
        } else if isCardDankort(cardNumber: cardNumber) {
            return CYBCardTypes.DANKORT
        } else if isCardMaestro(cardNumber: cardNumber) {
            return CYBCardTypes.MAESTRO
        } else if isCardDiner(cardNumber: cardNumber) {
            return CYBCardTypes.DINER
        } else if isCardUnionPay(cardNumber: cardNumber) {
            return CYBCardTypes.UNIONPAY
        }
        
        return CYBCardTypes.UNKNOWN
    }
    
    // Validate Card for type Visa Electron
    private static func isCardVisaElectron(cardNumber: String) -> Bool {
        let startIndex = cardNumber.startIndex
        let shortRange = startIndex..<cardNumber.index(startIndex, offsetBy: 4)
        let longRange = startIndex..<cardNumber.index(startIndex, offsetBy: 6)
        return cardNumber.range(of: "4026", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                cardNumber.range(of: "417500", options: .caseInsensitive, range: longRange, locale: nil) != nil ||
                cardNumber.range(of: "4405", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                cardNumber.range(of: "4508", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                cardNumber.range(of: "4844", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                cardNumber.range(of: "4913", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                cardNumber.range(of: "4917", options: .caseInsensitive, range: shortRange, locale: nil) != nil
    }
    
    // Validate Card for type American Express
    private static func isCardAmex(cardNumber: String) -> Bool {
        let range = cardNumber.startIndex..<cardNumber.index(cardNumber.startIndex, offsetBy: 2)
        return cardNumber.range(of: "34", options: .caseInsensitive, range: range, locale: nil) != nil ||
                cardNumber.range(of: "37", options: .caseInsensitive, range: range, locale: nil) != nil
    }
    
    // Validate Card for type Mastercard
    private static func isCardMastercard(cardNumber: String) -> Bool {
        if cardNumber.count > 2 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber = Int(cardNumber[..<index])
            return startingNumber! >= 51 && startingNumber! <= 55
        }
        return false
    }
    
    // Validate Card for type Discover
    private static func isCardDiscover(cardNumber: String) -> Bool {
        if cardNumber.count > 6 {
            let firstStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 3)
            let firstStartingNumber = Int(cardNumber[..<firstStartingIndex])!
            let secondStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 6)
            let secondStartingNumber = Int(cardNumber[..<secondStartingIndex])!
            let startIndex = cardNumber.startIndex
            let shortRange = startIndex..<cardNumber.index(startIndex, offsetBy: 2)
            let longRange = startIndex..<cardNumber.index(startIndex, offsetBy: 4)

            return (firstStartingNumber >= 644 && firstStartingNumber <= 649) ||
                    (secondStartingNumber >= 622126 && secondStartingNumber <= 622925) ||
                    cardNumber.range(of: "65", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                    cardNumber.range(of: "6011", options: .caseInsensitive, range: longRange, locale: nil) != nil
        }
        return false
    }
  
    // Validate Card for type JCB
    private static func isCardJCB(cardNumber: String) -> Bool {
        if cardNumber.count > 4 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 4)
            let startingNumber = Int(cardNumber[..<index])!
            return startingNumber >= 3528 && startingNumber <= 3589
        }
        return false
    }
    
    // Validate Card for type Dankort
    private static func isCardDankort(cardNumber: String) -> Bool {
        let range = cardNumber.startIndex..<cardNumber.index(cardNumber.startIndex, offsetBy: 4)
        return cardNumber.range(of: "5019", options: .caseInsensitive, range: range, locale: nil) != nil
    }
    
    // Validate Card for type Maestro
    private static func isCardMaestro(cardNumber: String) -> Bool{
        if cardNumber.count > 2 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber = Int(cardNumber[..<index])!
            return startingNumber == 50 ||
                    (startingNumber >= 56 && startingNumber <= 64) ||
                    (startingNumber >= 66 && startingNumber <= 69)  
        }
        return false
    }
    
    // Validate Card for type Diner
    private static func isCardDiner(cardNumber: String) -> Bool{
        if cardNumber.count > 2 {
            let index3 = cardNumber.index(cardNumber.startIndex, offsetBy: 3)
            let startingNumber3 = Int(cardNumber[..<index3])!
            let index2 = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber2 = Int(cardNumber[..<index2])!
            return startingNumber2 == 36 ||
                   startingNumber3 == 309 ||
                   (startingNumber3 >= 300 && startingNumber3 <= 305)
        }
        return false
    }

    // Validate Card for type UnionPay
    private static func isCardUnionPay(cardNumber: String) -> Bool{
        if cardNumber.count > 2 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber = Int(cardNumber[..<index])!
            return startingNumber == 62
        }
        return false
    }
    
    // MARK: - Networking

    private static let WEBAPI_FLEX_BASE_URL = "https://sandbox.webapi.visa.com"
    
    private static let STAGING_XENDIT_BASE_URL = "https://api-staging.xendit.co";
    private static let PRODUCTION_XENDIT_BASE_URL = "https://api.xendit.co";
    private static let PRODUCTION_XENDIT_HOST = "api.xendit.co";
    
    private static let TOKEN_CREDENTIALS_PATH = "credit_card_tokenization_configuration";
    private static let CREATE_CREDIT_CARD_PATH = "v2/credit_card_tokens";
    private static let GET_3DS_RECOMMENDATION_URL = "/3ds_bin_recommendation";
    private static let CREDIT_CARD_PATH = "credit_card_tokens";
    private static let AUTHENTICATION_PATH = "authentications";
    private static let TOKENIZE_CARD_PATH = "cybersource/flex/v1/tokens";
    
    private static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create credit card Xendit token
    private static func createCreditCardToken(cardData: CardData, shouldAuthenticate: Bool, onBehalfOf: String, completion: @escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)
        url?.appendPathComponent(CREATE_CREDIT_CARD_PATH)

        let header: [String: String] = [
            "for-user-id": onBehalfOf
        ]
        
        let requestBody = prepareCreateTokenBody(cardData: cardData, shouldAuthenticate: shouldAuthenticate)
        
        createTokenRequest(URL: url!, bodyJson: requestBody, extraHeader: header) { (token, error) in
            completion(token, error)
        }
    }

    // Get 3DS recommendation
    private static func get3DSRecommendation(tokenId: String, completion: @escaping (_ : Xendit3DSRecommendation?, _ : XenditError?) -> Void) {
        var components = URLComponents()

        components.scheme = "https"
        components.host = PRODUCTION_XENDIT_HOST
        components.path = GET_3DS_RECOMMENDATION_URL
        components.queryItems = [
            URLQueryItem(name: "token_id", value: tokenId)
        ]
        let url = components.url
        
        create3DSRecommendationRequest(URL: url!) { (recommendation, error) in
            completion(recommendation, error)
        }
    }
    
    // MARK: - Networking requests
    
    private static func tokenizeCardRequest(URL: URL, requestBody: [String:Any], completion: @escaping (_ : String?, _ : XenditError?) -> Void) {
        var request = URLRequest.request(ur: URL)
        request.httpMethod = "POST"

        Log.shared.logUrlRequest(prefix: "tokenizeCardRequest", request: request, requestBody: requestBody)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = bodyData
        } catch {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "tokenizeCardRequest", request: request, requestBody: requestBody, data: data, response: response, error: error)
            handleFlexResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handleError) in
                if parsedData != nil {
                    if let CYBToken = parsedData!["token"] as? String {
                        DispatchQueue.main.async {
                            completion(CYBToken, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handleError)
                    }
                }
            })
        }.resume()
    }

    private static func createAuthenticationRequest(URL: URL, bodyJson: [String:Any], extraHeader: [String:String], completion: @escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        var request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        request.httpMethod = "POST"
        request.setValue(extraHeader["for-user-id"], forHTTPHeaderField: "for-user-id")

        Log.shared.logUrlRequest(prefix: "createAuthenticationRequest", request: request, requestBody: bodyJson)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "createAuthenticationRequest", request: request, requestBody: bodyJson, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let authentication = XenditAuthentication.init(response: parsedData!)
                    if authentication != nil {
                        DispatchQueue.main.async {
                            completion(authentication, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
    private static func createTokenRequest(URL: URL, bodyJson: [String:Any], extraHeader: [String:String], completion: @escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        var request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        request.httpMethod = "POST"
        request.setValue(extraHeader["for-user-id"], forHTTPHeaderField: "for-user-id")
                
        Log.shared.logUrlRequest(prefix: "createTokenRequest", request: request, requestBody: bodyJson)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "createTokenRequest", request: request, requestBody: bodyJson, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let token = XenditCCToken.init(response: parsedData!)
                    if token != nil {
                        DispatchQueue.main.async {
                            completion(token, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }

    private static func create3DSRecommendationRequest(URL: URL, completion: @escaping (_ : Xendit3DSRecommendation?, _ : XenditError?) -> Void) {
        var request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        request.httpMethod = "GET"

        Log.shared.logUrlRequest(prefix: "create3DSRecommendationRequest", request: request, requestBody: nil)

        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "create3DSRecommendationRequest", request: request, requestBody: nil, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let token = Xendit3DSRecommendation.init(response: parsedData!)
                    if token != nil {
                        DispatchQueue.main.async {
                            completion(token, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
}
