//
//  Card.swift
//  Xendit
//
//  Created by xendit on 22/10/20.
//

import Foundation

class CreditCard {
    static func isValidCardNumber(cardNumber: String) -> Bool {
        guard cardNumber.count >= 9 else {
            return false
        }
        
        let originalCheckDigit = cardNumber.last!
        let characters = cardNumber.dropLast().reversed()
        
        var digitSum = 0
        
        for (idx, character) in characters.enumerated() {
            let value = Int(String(character)) ?? 0
            if idx % 2 == 0 {
                var product = value * 2
                
                if product > 9 {
                    product = product - 9
                }
                
                digitSum = digitSum + product
            }
            else {
                digitSum = digitSum + value
            }
        }
        
        digitSum = digitSum * 9
        
        let computedCheckDigit = digitSum % 10
        
        let originalCheckDigitInt = Int(String(originalCheckDigit))
        let valid = originalCheckDigitInt == computedCheckDigit
        return valid
    }
}
