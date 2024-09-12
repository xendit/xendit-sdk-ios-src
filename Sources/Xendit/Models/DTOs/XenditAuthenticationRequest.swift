//
//  XenditAuthenticationRequest.swift
//  Xendit
//
//  Created by xendit on 07/07/21.
//

import Foundation

@objcMembers
@objc(XenditAuthenticationRequest) open class XenditAuthenticationRequest: NSObject {
    
    public var amount: NSNumber
    public var tokenId: String
    public var currency: String
    public var cardCvn: String?
    public var midLabel: String?
    public var billingDetails: XenditBillingDetails?
    public var customer: XenditCustomer?
    public var cardData: XenditCardHolderInformation?
    
    public init(tokenId: String, amount: NSNumber, currency: String, cardData: XenditCardHolderInformation?) {
        self.amount = amount
        self.tokenId = tokenId
        self.currency = currency
        self.cardData = cardData
    }
}
