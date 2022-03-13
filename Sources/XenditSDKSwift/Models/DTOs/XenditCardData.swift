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

    public init(cardNumber: String, cardExpMonth: String, cardExpYear: String) {
        self.cardNumber = cardNumber
        self.cardExpMonth = cardExpMonth
        self.cardExpYear = cardExpYear
    }

}
