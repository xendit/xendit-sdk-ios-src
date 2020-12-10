//
//  Cards.swift
//  Xendit
//
//  Created by xendit on 28/10/20.
//

import Foundation
import CardinalMobile

protocol CanTokenize {
    // Tokenization method
    // @param cardData: Card and billing details
    // @param shouldAuthenticate: Specify if authentication is bundled with the tokenization
    // @param onBehalfOf (Optional) Business id for xenPlaform use cases
    // @param completion callback function when tokenization is completed
    static func createToken(fromViewController: UIViewController, tokenizationRequest: XenditTokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void)
}

protocol CanAuthenticate {
    // 3DS Authentication method
    // @param fromViewController The UIViewController from which will be present webview for 3DS Authentication
    // @param tokenId The credit card token id
    // @param amount The transaction amount
    // @param onBehalfOf (Optional) Business id for xenPlaform use cases
    // @param completion callback function when authentication is completed
    static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, onBehalfOf: String?, customer: XenditCustomer?, completion:@escaping (_: XenditAuthentication?, _: XenditError?) -> Void)
}

public class XDTCards: CanTokenize, CanAuthenticate {
    private static var cardAuthenticationProvider: CardAuthenticationProviderProtocol = CardAuthenticationProvider()
    private static var authenticationProvider: AuthenticationProviderProtocol = AuthenticationProvider()
    private static var cardinalSession: CardinalSession?
    private static var publishableKey: String?
    
    public static func setup(publishableKey: String) {
        XDTCards.publishableKey = publishableKey
    }
    
    private static func configureCardinal(environment: CardinalSessionEnvironment) {
        cardinalSession = CardinalSession()
        let config = CardinalSessionConfiguration()
        config.deploymentEnvironment = environment
        config.uiType = .both
        
        let yourCustomUi = UiCustomization()
        //Set various customizations here. See "iOS UI Customization" documentation for detail.
        config.uiCustomization = yourCustomUi
        config.renderType = [CardinalSessionRenderTypeOTP, CardinalSessionRenderTypeHTML]
        config.enableQuickAuth = true
        cardinalSession!.configure(config)
    }
    
    public static func createToken(fromViewController: UIViewController, tokenizationRequest: XenditTokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        let logPrefix = "createToken:"
        let cardData = tokenizationRequest.cardData
        
        if let error = validateTokenizationRequest(cardData: cardData) {
            Log.shared.verbose("\(logPrefix) \(error)")
            completion(nil, error)
        }
        
        var extraHeaders: [String: String] = [:]
        if onBehalfOf != "" {
            extraHeaders["for-user-id"] = onBehalfOf
        }
        
        let requestBody = tokenizationRequest.toJsonObject()
        
        XDTApiClient.createTokenRequest(publishableKey: publishableKey!, bodyJson: requestBody, extraHeader: extraHeaders) { (authenticatedToken, error) in
            if cardData.isMultipleUse == true && authenticatedToken != nil {
                get3DSRecommendation(tokenId: authenticatedToken!.id, completion: { (threeDSRecommendation, get3DSRecommendationError) in
                    let tokenWith3DSRecommendation = XenditCCToken(authenticatedToken: authenticatedToken!)
                    tokenWith3DSRecommendation?.should3DS = threeDSRecommendation?.should3DS ?? true
                    completion(tokenWith3DSRecommendation, nil);
                })
            } else {
                handleCreditCardTokenization(fromViewController: fromViewController, authenticatedToken: authenticatedToken, amount: cardData.amount, onBehalfOf: onBehalfOf, error: error, completion: completion)
            }
        }
    }
    
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, onBehalfOf: String?, customer: XenditCustomer?, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        let jwtRequest = XenditJWTRequest(amount: amount)
        jwtRequest.currency = "IDR" // TODO: allow other currencies
        jwtRequest.customer = customer
        
        XDTApiClient.getJWT(publishableKey: publishableKey!, tokenId: tokenId, requestBody: jwtRequest) {
            (jwt, error) in
                if error != nil || jwt?.jwt == nil {
                    // Continue with normal flow
                    create3DS1Authentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, onBehalfOf: onBehalfOf, completion: completion)
                } else {
                    // 3DS2 flow
                    let environment = jwt?.environment;
                    let jwt = jwt?.jwt
                    handleEmv3DSFlow(fromViewController: fromViewController, tokenId: tokenId, environment: environment!, amount: amount, jwt: jwt!, onBehalfOf: onBehalfOf) {
                        (token, error) in
                        if token == nil || error != nil {
                            completion(nil, error)
                        } else {
                            // mapping token response into authentication response
                            let authentication = XenditAuthentication(id: token!.authenticationId, status: token!.status, maskedCardNumber: token!.maskedCardNumber, metadata: token!.metadata)
                            completion(authentication, error)
                        }

                    }
                }
        }
    }
    
    private static func create3DS1Authentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, onBehalfOf: String?, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        let authenticationData = AuthenticationData()
        authenticationData.tokenId = tokenId
        authenticationData.amount = amount
        
        let requestBody = ["amount" : amount]
        
        var extraHeaders: [String: String] = [:]
        if onBehalfOf != nil || onBehalfOf != "" {
            extraHeaders["for-user-id"] = onBehalfOf
        }
        XDTApiClient.createAuthenticationRequest(publishableKey: publishableKey!, tokenId: tokenId, bodyJson: requestBody, extraHeader: extraHeaders) { (authentication, error) in
            handleCreateAuthentication(fromViewController: fromViewController, authentication: authentication, error: error, completion: completion)
        }
    }
    
    public static func get3DSRecommendation(tokenId: String, completion: @escaping (_ : Xendit3DSRecommendation?, _ : XenditError?) -> Void) {
        XDTApiClient.create3DSRecommendationRequest(publishableKey: publishableKey!, tokenId: tokenId, completion: completion)
    }
    
    private static func createAuthenticationWithSessionId(fromViewController: UIViewController, tokenId: String, sessionId: String, amount: NSNumber, onBehalfOf: String?, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        
        let requestBody: [String: Any] = [
            "amount" : amount,
            "session_id" : sessionId
        ]
        
        var header: [String: String] = [:]
        if onBehalfOf != nil {
            header["for-user-id"] = onBehalfOf!
        }
        
        XDTApiClient.createAuthenticationRequest(publishableKey: publishableKey!, tokenId: tokenId, bodyJson: requestBody, extraHeader: header) { (authentication, error) in
            if error != nil {
                return completion(nil, error)
            }
            let authenticationTransactionId = authentication?.authenticationTransactionId
            let requestPayload = authentication?.requestPayload
            if authenticationTransactionId == nil || requestPayload == nil {
                // Revert to 3DS1 flow
                create3DS1Authentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, onBehalfOf: onBehalfOf) { (authentication, error) in
                    if error != nil {
                        return completion(nil, error)
                    }
                    // Handle opening of OTP page
                    let token = XenditCCToken.init(tokenId: tokenId, authentication: authentication!)
                    return completion(token, nil)
                }
                return
            }
            
            let xdtDelegate = XDTValidationDelegate(completion: { (response, jwt, error) in
                verifyAuthentication(authentication: authentication!) { (authentication, error) in
                    guard error == nil else {
                        return completion(nil, error)
                    }
                    let token = XenditCCToken(tokenId: tokenId, authentication: authentication!);
                    return completion(token, error);
                }
            })
            
            cardinalSession?.continueWith(transactionId: authenticationTransactionId!, payload: requestPayload!, validationDelegate: xdtDelegate)
            return
        }
    }
    
    private static func verifyAuthentication(authentication: XenditAuthentication, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        
        let requestBody: [String: Any] = [
            "authentication_transaction_id": authentication.authenticationTransactionId!
        ]
        
        XDTApiClient.verifyAuthenticationRequest(publishableKey: publishableKey!, authenticationId: authentication.id, bodyJson: requestBody, extraHeader: nil, completion: completion)
    }
    
    
    private static func validateTokenizationRequest(cardData: CardData) -> XenditError? {
        guard publishableKey != nil else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key")
            
        }
        
        guard cardData.amount != nil && cardData.amount.intValue >= 0 else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Amount must be a number greater than 0")
        }
        
        guard cardData.cardNumber != nil && CreditCard.isValidCardNumber(cardNumber: cardData.cardNumber) else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Card number is invalid")
            
        }
        
        guard cardData.cardExpMonth != nil && cardData.cardExpYear != nil && CreditCard.isExpiryValid(cardExpirationMonth: cardData.cardExpMonth, cardExpirationYear: cardData.cardExpYear) else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Card expiration date is invalid")
            
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && CreditCard.isCvnValid(creditCardCVN: cardData.cardCvn!) else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid")
                
            }
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && cardData.cardNumber != nil && CreditCard.isCvnValidForCardType(creditCardCVN: cardData.cardCvn!, cardNumber: cardData.cardNumber!) else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid for this card type")
            }
        }
        return nil
    }
    
    private static func handleCreditCardTokenization(fromViewController: UIViewController, authenticatedToken: XenditAuthenticatedToken?, amount: NSNumber, onBehalfOf: String?, error: XenditError?, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        if let error = error {
            // handle error message
            if error.errorCode == "INVALID_USER_ID" {
                error.message = error.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
            }
            return completion(nil, error)
        }
        
        let status = authenticatedToken?.status
        let jwt = authenticatedToken?.jwt
        
        guard let tokenId = authenticatedToken?.id else {
            return completion(nil, XenditError.ServerError())
        }
        
        if status != nil {
            if status == "IN_REVIEW" {
                if authenticatedToken?.threedsVersion == "2.0" && jwt != nil {
                    handleEmv3DSFlow(fromViewController: fromViewController, tokenId: tokenId, environment: authenticatedToken!.environment!, amount: amount, jwt: jwt!, onBehalfOf: onBehalfOf, completion: completion)
                } else if let authenticationURL = authenticatedToken?.authenticationURL {
                    cardAuthenticationProvider.authenticate(
                        fromViewController: fromViewController,
                        URL: authenticationURL,
                        authenticatedToken: authenticatedToken!,
                        completion: completion
                    )
                }
            } else {
                let token = XenditCCToken(authenticatedToken: authenticatedToken!)
                completion(token, nil)
            }
        } else {
            completion(nil, XenditError.ServerError())
        }
    }
    
    private static func handleEmv3DSFlow(fromViewController: UIViewController, tokenId: String, environment: String, amount: NSNumber, jwt: String, onBehalfOf: String?, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        let cardinalEnvironment = environment == "DEVELOPMENT" ? CardinalSessionEnvironment.staging : CardinalSessionEnvironment.production;
        configureCardinal(environment: cardinalEnvironment);
        cardinalSession?.setup(jwtString: jwt, completed: {
            (sessionId: String) in
            createAuthenticationWithSessionId(fromViewController: fromViewController, tokenId: tokenId, sessionId: sessionId, amount: amount, onBehalfOf: onBehalfOf, completion: completion)
        }) {
            (response : CardinalResponse) in
                // Revert to 3DS1 flow
            create3DS1Authentication(fromViewController: fromViewController, tokenId: tokenId, amount: amount, onBehalfOf: onBehalfOf) { (authentication, error) in
                    if error != nil {
                        return completion(nil, error)
                    }
                    // Handle opening of OTP page
                    let token = XenditCCToken.init(tokenId: tokenId, authentication: authentication!)
                    return completion(token, nil)
                }
                return
        }
    }
    
    private static func handleCreateAuthentication(fromViewController: UIViewController, authentication: XenditAuthentication?, error: XenditError?, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        if (error != nil) {
            // handle error message
            if error!.errorCode == "INVALID_USER_ID" {
                error!.message = error!.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
            }
            completion(nil, error);
            return
        }
        
        let status = authentication?.status
        
        if status != nil {
            if status == "IN_REVIEW", let authenticationURL = authentication?.authenticationURL {
                authenticationProvider.authenticate(
                    fromViewController: fromViewController,
                    URL: authenticationURL,
                    authentication: authentication!,
                    completion: completion
                )
            } else {
                completion(authentication, nil)
            }
        } else {
            completion(nil, XenditError.ServerError())
        }
    }
}


class XDTValidationDelegate: CardinalValidationDelegate {
    private var completion:  (_ : CardinalResponse?, _ : String?, _ : XenditError?) -> Void
    init(completion: @escaping (_ : CardinalResponse?, _ : String?, _ : XenditError?) -> Void) {
        self.completion = completion
    }
    func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
        self.completion(validateResponse, serverJWT, nil);
    }
}
