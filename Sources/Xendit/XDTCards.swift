//
//  Cards.swift
//  Xendit
//
//  Created by xendit on 28/10/20.
//

import Foundation
import UIKit

protocol CanTokenize {
    // Tokenization method
    // @param tokenizationRequest: Card and billing details
    // @param onBehalfOf (Optional) Business id for xenPlaform use cases
    // @param completion callback function when tokenization is completed
    static func createToken(fromViewController: UIViewController, tokenizationRequest: XenditTokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void)
    
    // Retokenization method
    // @param retokenizationRequest: Token ID and billing details
    // @param onBehalfOf (Optional) Business id for xenPlaform use cases
    // @param completion callback function when tokenization is completed
    static func createToken(fromViewController: UIViewController, retokenizationRequest: XenditRetokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void)
    
    // Store CVN method
    // @param storeCVNRequest: Token ID and billing details
    // @param onBehalfOf (Optional) Business id for xenPlaform use cases
    // @param completion callback function when tokenization is completed
    static func storeCVN(fromViewController: UIViewController, storeCVNRequest: XenditStoreCVNRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void)
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
    private static var publishableKey: String?
    
    public static func setup(publishableKey: String) {
        XDTCards.publishableKey = publishableKey
    }
    
    public static func createToken(fromViewController: UIViewController, tokenizationRequest: XenditTokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        let logPrefix = "createToken:"
        let currency = tokenizationRequest.currency
        
        if let error = validateTokenizationRequest(tokenizationRequest: tokenizationRequest) {
            Log.shared.verbose("\(logPrefix) \(error)")
            return completion(nil, error)
        }
        
        var extraHeaders: [String: String] = [:]
        if onBehalfOf != "" {
            extraHeaders["for-user-id"] = onBehalfOf
        }
        
        let requestBody = tokenizationRequest.toJsonObject()
        
        XDTApiClient.createTokenRequest(publishableKey: publishableKey!, bodyJson: requestBody, extraHeader: extraHeaders) { (authenticatedToken, error) in
            if tokenizationRequest.isSingleUse == false && authenticatedToken != nil {
                get3DSRecommendation(tokenId: authenticatedToken!.id, completion: { (threeDSRecommendation, get3DSRecommendationError) in
                    let tokenWith3DSRecommendation = XenditCCToken(authenticatedToken: authenticatedToken!)
                    tokenWith3DSRecommendation?.should3DS = threeDSRecommendation?.should3DS ?? true
                    completion(tokenWith3DSRecommendation, nil);
                })
            } else {
                handleCreditCardTokenization(fromViewController: fromViewController, authenticatedToken: authenticatedToken, amount: tokenizationRequest.amount ?? 0, currency: currency, onBehalfOf: onBehalfOf, cardCvn: tokenizationRequest.cardData.cardCvn, error: error, completion: completion)
            }
        }
    }
    
    @available(*, deprecated, message: "Use storeCVN(UIViewController, XenditStoreCVNRequest, String, Callback) instead")
    public static func createToken(fromViewController: UIViewController, retokenizationRequest: XenditRetokenizationRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        let logPrefix = "createToken:"
        
        if let error = validateRetokenizationRequest(retokenizationRequest: retokenizationRequest) {
            Log.shared.verbose("\(logPrefix) \(error)")
            return completion(nil, error)
        }
        
        var extraHeaders: [String: String] = [:]
        if onBehalfOf != "" {
            extraHeaders["for-user-id"] = onBehalfOf
        }
        
        let requestBody = retokenizationRequest.toJsonObject()
        
        XDTApiClient.createTokenRequest(publishableKey: publishableKey!, bodyJson: requestBody, extraHeader: extraHeaders) { (authenticatedToken, error) in
            
            handleCreditCardTokenization(fromViewController: fromViewController, authenticatedToken: authenticatedToken, amount: 0, currency: nil, onBehalfOf: onBehalfOf, cardCvn: retokenizationRequest.cardCvn, error: error, completion: completion)
        }
    }
    
    public static func storeCVN(fromViewController: UIViewController, storeCVNRequest: XenditStoreCVNRequest, onBehalfOf: String?, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        let logPrefix = "storeCVN:"
        
        if let error = validateRetokenizationRequest(retokenizationRequest: storeCVNRequest) {
            Log.shared.verbose("\(logPrefix) \(error)")
            return completion(nil, error)
        }
        
        var extraHeaders: [String: String] = [:]
        if onBehalfOf != "" {
            extraHeaders["for-user-id"] = onBehalfOf
        }
        
        let requestBody = storeCVNRequest.toJsonObject()
        
        XDTApiClient.createTokenRequest(publishableKey: publishableKey!, bodyJson: requestBody, extraHeader: extraHeaders) { (authenticatedToken, error) in
            
            handleCreditCardTokenization(fromViewController: fromViewController, authenticatedToken: authenticatedToken, amount: 0, currency: nil, onBehalfOf: onBehalfOf, cardCvn: storeCVNRequest.cardCvn, error: error, completion: completion)
        }
    }
    
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, onBehalfOf: String?, customer: XenditCustomer?, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        
        createAuthentication(
            fromViewController: fromViewController,
            tokenId: tokenId,
            amount: amount,
            currency: nil,
            onBehalfOf: onBehalfOf,
            customer: customer,
            completion: completion);
    }
    
    public static func createAuthentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, currency: String?, onBehalfOf: String?, customer: XenditCustomer?, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        
        createAuthentication(
            fromViewController: fromViewController,
            tokenId: tokenId,
            amount: amount,
            currency: currency,
            onBehalfOf: onBehalfOf,
            customer: customer,
            cardCvn: nil,
            completion: completion
        );
    }
    
    public static func createAuthentication(
        fromViewController: UIViewController,
        tokenId: String,
        amount: NSNumber,
        currency: String?,
        onBehalfOf: String?,
        customer: XenditCustomer?,
        cardCvn: String?,
        completion: @escaping (XenditAuthentication?, XenditError?) -> Void
    ) {
        createAuthentication(
            fromViewController: fromViewController,
            tokenId: tokenId,
            amount: amount,
            currency: currency,
            onBehalfOf: onBehalfOf,
            customer: customer,
            cardCvn: cardCvn,
            cardData: nil,
            completion: completion
        );
    }
    
    public static func createAuthentication(
        fromViewController: UIViewController,
        tokenId: String,
        amount: NSNumber,
        currency: String?,
        onBehalfOf: String?,
        customer: XenditCustomer?,
        cardCvn: String?,
        cardData: XenditCardHolderInformation?,
        completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        create3DS1Authentication(
            fromViewController: fromViewController,
            tokenId: tokenId,
            amount: amount,
            currency: currency,
            onBehalfOf: onBehalfOf,
            cardCvn: cardCvn,
            cardData: cardData,
            completion: completion
        )
    }
    
    private static func create3DS1Authentication(fromViewController: UIViewController, tokenId: String, amount: NSNumber, currency: String?, onBehalfOf: String?, cardCvn: String?, cardData: XenditCardHolderInformation?, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        if publishableKey == nil {
            completion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key"))
            return
        }
        
        var requestBody: [String:  Any] = [
            "amount" : amount
        ]
        
        if currency != nil {
            requestBody["currency"] = currency
        }
        
        if cardCvn != nil {
            requestBody["card_cvn"] = cardCvn
        }
        
        if let cardData, !cardData.isEmpty() {
            requestBody["card_data"] = cardData.toJsonObject()
        }
        
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
    
    private static func validateTokenizationRequest(tokenizationRequest: XenditTokenizationRequest) -> XenditError? {
        let cardData = tokenizationRequest.cardData
        guard publishableKey != nil else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key")
        }
        
        if (tokenizationRequest.isSingleUse) {
            if (tokenizationRequest.amount != nil) {
                guard tokenizationRequest.amount!.doubleValue >= 0 else {
                    return XenditError(errorCode: "VALIDATION_ERROR", message: "Amount must not be less than 0")
                }
            } else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Amount is required for single use token")
            }
        } else {
            if (tokenizationRequest.amount != nil) {
                guard tokenizationRequest.amount!.doubleValue >= 0 else {
                    return XenditError(errorCode: "VALIDATION_ERROR", message: "Amount must not be less than 0")
                }
            }
        }
        
        guard CreditCard.isValidCardNumber(cardNumber: cardData.cardNumber) else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Card number is invalid")
        }
        
        guard CreditCard.isExpiryValid(cardExpirationMonth: cardData.cardExpMonth, cardExpirationYear: cardData.cardExpYear) else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Card expiration date is invalid")
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard cardData.cardCvn != nil && CreditCard.isCvnValid(creditCardCVN: cardData.cardCvn!) else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid")
            }
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            guard CreditCard.isCvnValidForCardType(creditCardCVN: cardData.cardCvn!, cardNumber: cardData.cardNumber) else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid for this card type")
            }
        }
        return nil
    }
    
    private static func validateRetokenizationRequest(retokenizationRequest: XenditRetokenizationRequest) -> XenditError? {
        guard publishableKey != nil else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Empty publishable key")
        }
        
        guard retokenizationRequest.tokenId != "" else {
            return XenditError(errorCode: "VALIDATION_ERROR", message: "Empty token ID")
        }
        
        if retokenizationRequest.cardCvn != nil && retokenizationRequest.cardCvn != "" {
            guard retokenizationRequest.cardCvn != nil && CreditCard.isCvnValid(creditCardCVN: retokenizationRequest.cardCvn!) else {
                return XenditError(errorCode: "VALIDATION_ERROR", message: "Card CVN is invalid")
            }
        }
        
        return nil
    }
    
    private static func handleCreditCardTokenization(fromViewController: UIViewController, authenticatedToken: XenditAuthenticatedToken?, amount: NSNumber, currency: String?, onBehalfOf: String?, cardCvn: String?, error: XenditError?, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        if let error = error {
            // handle error message
            if error.errorCode == "INVALID_USER_ID" {
                error.message = error.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
            }
            return completion(nil, error)
        }
        
        let status = authenticatedToken?.status
        
        guard authenticatedToken?.id != nil else {
            return completion(nil, XenditError.ServerError())
        }
        
        if status != nil {
            if status == "IN_REVIEW", let authenticationURL = authenticatedToken?.authenticationURL {
                cardAuthenticationProvider.authenticate(
                    fromViewController: fromViewController,
                    URL: authenticationURL,
                    authenticatedToken: authenticatedToken!,
                    completion: completion
                )
            } else {
                let token = XenditCCToken(authenticatedToken: authenticatedToken!)
                completion(token, nil)
            }
        } else {
            completion(nil, XenditError.ServerError())
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
