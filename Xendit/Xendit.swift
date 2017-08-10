//
//  Xendit.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/15/17.
//
//

import Foundation

@objc(Xendit) open class Xendit: NSObject {
    
    // MARK: - Public methods
    
    // Publishable key
    open static var publishableKey: String?

    // Create token method
    open static func createToken(fromViewController: UIViewController, cardData: CardData!, shouldAuthenticate: Bool, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        guard publishableKey != nil else {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        guard cardData.amount != nil && cardData.amount.intValue > 0 else {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Amount must be a number greater than 0"))
            return
        }
        
        guard cardData.cardNumber != nil && isCardNumberValid(cardNumber: cardData.cardNumber) else {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Card number is invalid"))
            return
        }
        
        guard cardData.cardExpMonth != nil && cardData.cardExpYear != nil && isExpiryValid(cardExpirationMonth: cardData.cardExpMonth, cardExpirationYear: cardData.cardExpYear) else {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Card expiration date is invalid"))
            return
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && isCvnValid(creditCardCVN: cardData.cardCvn!) else {
                completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid"))
                return
            }
        }

        getTokenizationCredentials { (tokenCredentials, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            tokenizeCreditCard(cardData: cardData, tokenCredentials: tokenCredentials!, completion: { (CYBToken, error) in
                if CYBToken != nil {
                    createCreditCardToken(CYBToken: CYBToken!, cardData: cardData, shouldAuthenticate: shouldAuthenticate, completion: { (xenditToken, createTokenError) in
                        handleCreateCardToken(fromViewController: fromViewController, token: xenditToken, error: createTokenError, completion: completion)
                    })
                } else {
                    completion(nil, error)
                }
            })
        }
    }

    open static func createToken(fromViewController: UIViewController, cardData: CardData!, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        createToken(fromViewController: fromViewController, cardData: cardData, shouldAuthenticate: true, completion: completion);
    }
    
    // 3DS Authentication method
    // @param fromViewController The UIViewController from which will be present webview for 3DS Authentication
    // @param tokenId The credit card token id
    // @param amount The transaction amount
    // @param cardCVN The credit card CVN code for create token
    @available(*, deprecated:1.1, message:"cvn no longer used")
    open static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, cardCVN: String, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        self.createAuthentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, completion: completion)
    }
    
    // 3DS Authentication method
    // @param fromViewController The UIViewController from which will be present webview for 3DS Authentication
    // @param tokenId The credit card token id
    // @param amount The transaction amount
    open static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        let authenticationData = AuthenticationData()
        authenticationData.tokenId = tokenId
        authenticationData.amount = amount
        
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)
        url?.appendPathComponent(CREATE_CREDIT_CARD_PATH)
        url?.appendPathComponent(tokenId)
        url?.appendPathComponent(AUTHENTICATION_PATH)
        let requestBody = prepareCreateAuthenticationBody(authenticationData: authenticationData)
        
        createAuthenticationRequest(URL: url!, bodyJson: requestBody) { (authentication, error) in
            handleCreateAuthentication(fromViewController: fromViewController, authentication: authentication, error: error, completion: completion)
        }
    }


    // Card data validation method
    open static func isCardNumberValid(cardNumber: String) -> Bool {
        return NSRegularExpression.regexCardNumberValidation(cardNumber: cardNumber) &&
                cardNumber.characters.count >= 12 &&
                cardNumber.characters.count <= 19 &&
                getCardType(cardNumber: cardNumber) != CYBCardTypes.UNKNOWN
    }

    // Card expiration date validation method
    open static func isExpiryValid(cardExpirationMonth: String, cardExpirationYear: String) -> Bool {
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
    open static func isCvnValid(creditCardCVN: String) -> Bool {
        let cvnLenght = creditCardCVN.characters.count
        return NSRegularExpression.regexCardNumberValidation(cardNumber: creditCardCVN) && (cvnLenght == 3 || cvnLenght == 4)
    }

    // MARK: - Privat methods
    
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
        if cardNumber.characters.count > 2 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber = Int(cardNumber.substring(to: index))
            return startingNumber! >= 51 && startingNumber! <= 55
        }
        return false
    }
    
    // Validate Card for type Discover
    private static func isCardDiscover(cardNumber: String) -> Bool {
        if cardNumber.characters.count > 6 {
            let firstStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 3)
            let firstStartingNumber = Int(cardNumber.substring(to: firstStartingIndex))!
            let secondStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 6)
            let secondStartingNumber = Int(cardNumber.substring(to: secondStartingIndex))!
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
        if cardNumber.characters.count > 4 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 4)
            let startingNumber = Int(cardNumber.substring(to: index))!
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
        if cardNumber.characters.count > 2 {
            let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
            let startingNumber = Int(cardNumber.substring(to: index))!
            return startingNumber == 50 ||
                    (startingNumber >= 56 && startingNumber <= 64) ||
                    (startingNumber >= 66 && startingNumber <= 69)  
        }
        return false
    }
    
    // MARK: - Networking

    private static let WEBAPI_FLEX_BASE_URL = "https://sandbox.webapi.visa.com"
    
    private static let STAGING_XENDIT_BASE_URL = "https://api-staging.xendit.co";
    private static let PRODUCTION_XENDIT_BASE_URL = "https://api.xendit.co";
    
    private static let TOKEN_CREDENTIALS_PATH = "credit_card_tokenization_configuration";
    private static let CREATE_CREDIT_CARD_PATH = "credit_card_tokens";
    private static let AUTHENTICATION_PATH = "authentications";
    private static let TOKENIZE_CARD_PATH = "cybersource/flex/v1/tokens";
    
    private static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Get tokenizition credentials
    private static func getTokenizationCredentials(completion: @escaping (_ : XenditTokenCredentials?, _ : XenditError?) -> Void) {
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)
        url?.appendPathComponent(TOKEN_CREDENTIALS_PATH)
    
        tokenizationCredentialsRequest(URL: url!) { (tokenCredentials, error) in
            completion(tokenCredentials, error)
        }
    }
    
    // Tokenize Card. Returns a token representing the supplied card details.
    private static func tokenizeCreditCard(cardData: CardData, tokenCredentials: XenditTokenCredentials, completion: @escaping (_ : String?, _ : XenditError?) -> Void) {
        let flexBaseUrl = isProductionPublishableKey() ? tokenCredentials.flexProductionURL! : tokenCredentials.flexDevelopmentURL!
        var url = URL.init(string: flexBaseUrl)!
        url.appendPathComponent(TOKENIZE_CARD_PATH)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "apikey", value: tokenCredentials.flexApiKey)]
        
        let cardType = getCardType(cardNumber: cardData.cardNumber).stringValue()
        let requestBody = prepareTokenizeCreditCardBody(cardData: cardData, tokenCredentials: tokenCredentials, cardType: cardType)
        
        tokenizeCardRequest(URL: components.url!, requestBody: requestBody) { (CYBToken, error) in
            completion(CYBToken, error)
        }
    }
    
    // Create credit card Xendit token
    private static func createCreditCardToken(CYBToken: String, cardData: CardData, shouldAuthenticate: Bool, completion: @escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)
        url?.appendPathComponent(CREATE_CREDIT_CARD_PATH)
        let requestBody = prepareCreateTokenBody(cardToken: CYBToken, cardData: cardData, shouldAuthenticate: shouldAuthenticate)
        
        createTokenRequest(URL: url!, bodyJson: requestBody) { (token, error) in
            completion(token, error)
        }
    }
    
    // MARK: - Networking requests
    
    private static func tokenizeCardRequest(URL: URL, requestBody: [String:Any], completion: @escaping (_ : String?, _ : XenditError?) -> Void) {
        var request = URLRequest.request(ur: URL)
        request.httpMethod = "POST"
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = bodyData
        } catch {
            completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            handleFlexResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handleError) in
                if parsedData != nil {
                    if let CYBToken = parsedData!["token"] as? String {
                        completion(CYBToken, nil)
                    } else {
                        completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                    }
                } else {
                    completion(nil, handleError)
                }
            })
        }.resume()
    }

    private static func createAuthenticationRequest(URL: URL,  bodyJson: [String:Any], completion: @escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        var request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        request.httpMethod = "POST"

        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let authentication = XenditAuthentication.init(response: parsedData!)
                    if authentication != nil {
                        completion(authentication, nil)
                    } else {
                        completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                    }
                } else {
                    completion(nil, handledError)
                }
            })
        }.resume()
    }
    
    private static func createTokenRequest(URL: URL,  bodyJson: [String:Any], completion: @escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        var request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        request.httpMethod = "POST"
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let token = XenditCCToken.init(response: parsedData!)
                    if token != nil {
                        completion(token, nil)
                    } else {
                        completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                    }
                } else {
                    completion(nil, handledError)
                }
            })
        }.resume()
    }
    
    private static func tokenizationCredentialsRequest(URL: URL, completion: @escaping (_ : XenditTokenCredentials?, _ : XenditError?) -> Void) {
        let request = URLRequest.authorizationRequest(url: URL, publishableKey: publishableKey!)
        session.dataTask(with: request) { (data, response, error) in
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handleError) in
                if parsedData != nil {
                    let tokenCredentials = XenditTokenCredentials.init(dictionary: parsedData!)
                    if tokenCredentials != nil {
                        completion(tokenCredentials, nil)
                    } else {
                        completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                    }
                } else {
                    completion(nil, handleError)
                }
            })
        }.resume()
    }
}
