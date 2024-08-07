//
//  XenditCardData.swift
//  Xendit
//
//  Created by xendit on 07/07/21.
//

import Foundation
@objcMembers
@objc(XenditCardData) open class XenditCardData: NSObject {
    
    // Card Number value
    open var cardNumber: String
    
    // Card expiration month value
    open var cardExpMonth: String
    
    // Card expiration year value
    open var cardExpYear: String
    
    // Card verification number (CVN) value
    open var cardCvn: String?

    // Card holder first name value
    open var cardHolderFirstName: String?

    // Card holder first name value
    open var cardHolderLastName: String?

    // Card holder first name value
    open var cardHolderEmail: String?

    // Card holder first name value
    open var cardHolderPhoneNumber: String?

    

    public init(
        cardNumber: String,
        cardExpMonth: String,
        cardExpYear: String,
        cardHolderFirstName: String? = nil,
        cardHolderLastName: String? = nil,
        cardHolderEmail: String? = nil,
        cardHolderPhoneNumber: String? = nil
        ) {
        self.cardNumber = cardNumber
        self.cardExpMonth = cardExpMonth
        self.cardExpYear = cardExpYear
        self.cardHolderFirstName = cardHolderFirstName
        self.cardHolderLastName = cardHolderLastName
        self.cardHolderEmail = cardHolderEmail
        self.cardHolderPhoneNumber = cardHolderPhoneNumber
    }

}
