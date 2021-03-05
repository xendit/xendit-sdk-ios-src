//
//  XenditTokenizationRequest.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

public class XenditTokenizationRequest: JsonSerializable {
    
    public var amount: NSNumber
    public var isSingleUse: Bool
    public var shouldAuthenticate: Bool
    public var cardData: CardData
    public var midLabel: String?
    public var currency: String?
    public var billingDetails: XenditBillingDetails?
    public var customer: XenditCustomer?
    
    public init(cardData: CardData, shouldAuthenticate: Bool) {
        self.cardData = cardData
        self.isSingleUse = !cardData.isMultipleUse
        self.shouldAuthenticate = shouldAuthenticate
        self.amount = cardData.amount
        self.currency = cardData.currency
    }
    
    func toJsonObject() -> [String : Any] {
        // To be refactored using a request API DTO
        var cardDataJson: [String: String] = [
            "account_number": cardData.cardNumber,
            "exp_month": cardData.cardExpMonth,
            "exp_year": cardData.cardExpYear,
        ]
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            cardDataJson["cvn"] = cardData.cardCvn
        }
        
        var json: [String: Any] = [
            "should_authenticate": shouldAuthenticate,
            "card_data": cardDataJson,
            "is_single_use": !cardData.isMultipleUse
        ]
        
        if (currency != nil) {
            json["currency"] = currency;
        }
        
        if (!cardData.isMultipleUse) {
            json["amount"] = cardData.amount;
        }
        
        if (billingDetails != nil) {
            json["billing_details"] = billingDetails!.toJsonObject()
        }
        
        if (customer != nil) {
            json["customer"] = customer!.toJsonObject()
        }
        
        return json
    }
    
}
