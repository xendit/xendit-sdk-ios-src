//
//  XenditCardHolderInformation.swift
//  Xendit
//
//  Created by xendit on 07/07/21.
//

import Foundation
@objcMembers
@objc(XenditCardHolderInformation) open class XenditCardHolderInformation: NSObject {
    
    // Card holder first name value
    open var cardHolderFirstName: String?

    // Card holder first name value
    open var cardHolderLastName: String?

    // Card holder first name value
    open var cardHolderEmail: String?

    // Card holder first name value
    open var cardHolderPhoneNumber: String?

    public init(
        cardHolderFirstName: String? = nil,
        cardHolderLastName: String? = nil,
        cardHolderEmail: String? = nil,
        cardHolderPhoneNumber: String? = nil
        ) {
        self.cardHolderFirstName = cardHolderFirstName
        self.cardHolderLastName = cardHolderLastName
        self.cardHolderEmail = cardHolderEmail
        self.cardHolderPhoneNumber = cardHolderPhoneNumber
    }
    
    func toJsonObject() -> [String : Any] {
        var json: [String: Any] = [:]
        if cardHolderFirstName != nil { json["card_holder_first_name"] = cardHolderFirstName }
        if cardHolderLastName != nil { json["card_holder_last_name"] = cardHolderLastName }
        if cardHolderEmail != nil { json["email"] = cardHolderEmail }
        if cardHolderPhoneNumber != nil { json["mobile_number"] = cardHolderPhoneNumber }
        return json
    }

}
