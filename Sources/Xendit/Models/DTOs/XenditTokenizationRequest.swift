//
//  XenditTokenizationRequest.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

@objcMembers
@objc(XenditTokenizationRequest) public class XenditTokenizationRequest: NSObject, JsonSerializable {
    
    public var amount: NSNumber?
    public var isSingleUse: Bool
    public var shouldAuthenticate: Bool
    public var cardData: XenditCardData
    public var midLabel: String?
    public var currency: String?
    public var billingDetails: XenditBillingDetails?
    public var customer: XenditCustomer?
    
    @available(*, deprecated, message: "Use init(cardData: XenditCardData, isSingleUse: Bool, shouldAuthenticate: Bool, amount: NSNumber, currency: String) instead" )
    public init(cardData: CardData, shouldAuthenticate: Bool) {
        self.cardData = XenditCardData.init(
            cardNumber: cardData.cardNumber,
            cardExpMonth: cardData.cardExpMonth,
            cardExpYear: cardData.cardExpYear
        )
        self.cardData.cardCvn = cardData.cardCvn
        self.isSingleUse = !cardData.isMultipleUse
        self.shouldAuthenticate = shouldAuthenticate
        self.amount = cardData.amount
        self.currency = cardData.currency
    }
    
    public init (
        cardData: XenditCardData,
        isSingleUse: Bool,
        shouldAuthenticate: Bool,
        amount: NSNumber?,
        currency: String?
    ) {
        self.cardData = cardData
        self.isSingleUse = isSingleUse
        self.shouldAuthenticate = shouldAuthenticate
        if (amount != nil) {
            self.amount = amount
        }
        self.currency = currency
    }
    
    func toJsonObject() -> [String : Any] {
        // To be refactored using a request API DTO
        var cardDataJson: [String: String] = [
            "account_number": cardData.cardNumber,
            "exp_month": cardData.cardExpMonth,
            "exp_year": cardData.cardExpYear
        ]
        
        if let firstName = cardData.cardHolderFirstName, !firstName.isEmpty {
            cardDataJson["card_holder_first_name"] = firstName
        }

        if let lastName = cardData.cardHolderLastName, !lastName.isEmpty {
            cardDataJson["card_holder_last_name"] = lastName
        }

        if let email = cardData.cardHolderEmail, !email.isEmpty {
            cardDataJson["card_holder_email"] = email
        }

        if let phoneNumber = cardData.cardHolderPhoneNumber, !phoneNumber.isEmpty {
            cardDataJson["card_holder_phone_number"] = phoneNumber
        }
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            cardDataJson["cvn"] = cardData.cardCvn
        }
        
        var json: [String: Any] = [
            "should_authenticate": shouldAuthenticate,
            "card_data": cardDataJson,
            "is_single_use": isSingleUse
        ]
        
        if (currency != nil) {
            json["currency"] = currency;
        }
        
        if (isSingleUse) {
            json["amount"] = amount;
        }
        
        if (billingDetails != nil) {
            json["billing_details"] = billingDetails!.toJsonObject()
        }
        
        if (customer != nil) {
            json["customer"] = customer!.toJsonObject()
        }
        
        if (midLabel != nil) {
            json["mid_label"] = midLabel
        }
        
        return json
    }
    
}
