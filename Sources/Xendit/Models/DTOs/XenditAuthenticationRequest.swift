//
//  XenditAuthenticationRequest.swift
//  Xendit
//
//  Created by xendit on 07/07/21.
//

import Foundation

@objcMembers
@objc(XenditAuthenticationRequest) open class XenditAuthenticationRequest: NSObject, JsonSerializable {
    
    public var amount: NSNumber
    public var tokenId: String
    public var currency: String
    public var cardCvn: String?
    public var midLabel: String?
    public var billingDetails: XenditBillingDetails?
    public var customer: XenditCustomer?
    public var cardData: XenditCardHolderInformation?
    
    public init(tokenId: String, amount: NSNumber, currency: String, CardData: XenditCardHolderInformation?) {
        self.amount = amount
        self.tokenId = tokenId
        self.currency = currency
        self.cardData = CardData
    }
    
    func toJsonObject() -> [String : Any] {
        
        var json: [String: Any] = [
            "amount": amount,
            "credit_card_token_id": tokenId,
            "currency": currency
        ]
        
        if (midLabel != nil) {
            json["mid_label"] = midLabel
        }
        
        if (billingDetails != nil) {
            json["billing_details"] = billingDetails!.toJsonObject()
        }
        
        if (cardCvn != nil) {
            json["card_cvn"] = cardCvn
        }
        
        if (customer != nil) {
            json["customer"] = customer!.toJsonObject()
        }

        if (cardData != nil) {
            json["card_data"] = cardData!.toJsonObject()
        }
        
        return json
    }
}
