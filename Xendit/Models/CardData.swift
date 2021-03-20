//
//  CardData.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/15/17.
//
//

import Foundation

public enum CYBCardTypes {
    case VISA
    case MASTERCARD
    case AMEX
    case DISCOVER
    case JCB
    case VISA_ELECTRON
    case DANKORT
    case MAESTRO
    case DINER
    case UNIONPAY
    case UNKNOWN
    
    func stringValue() -> String {
        switch self {
        case .VISA:
            return "001"
        case .MASTERCARD:
            return "002"
        case .AMEX:
            return "003"
        case .DISCOVER:
            return "004"
        case .JCB:
            return "007"
        case .VISA_ELECTRON:
            return "033"
        case .DANKORT:
            return "034"
        case .MAESTRO:
            return "042"
        case .DINER:
            return "005"
        case .UNIONPAY:
            return "062"
        case .UNKNOWN:
            return "0"
        }
    }
}

@objcMembers
@objc(XENCardData) open class CardData: NSObject {
    
    // Card Number value
    open var cardNumber: String!
    
    // Card expiration month value
    open var cardExpMonth: String!
    
    // Card expiration year value
    open var cardExpYear: String!
    
    // Card verification number (CVN) value
    open var cardCvn: String?
    
    // Card transaction amount
    open var amount: NSNumber!

    // Multiple use flag
    open var isMultipleUse: Bool

    public override init() {
        self.isMultipleUse = false
        self.amount = 0;
    }

    open var maskedNumber: String {
        guard let cardNumber = cardNumber, cardNumber.count > 8 else {
            return self.cardNumber ?? ""
        }
        let asterisk = String(repeating: "*", count: cardNumber.count - 8)
        return "\(cardNumber.prefix(4))\(asterisk)\(cardNumber.suffix(4)))"
    }

    open override var description: String {
        return "CardData(cardNumber: \(maskedNumber), amount: \(amount?.description ?? "nil"))"
    }
}
