//
//  Card.swift
//  Xendit
//
//  Created by xendit on 22/10/20.
//

import Foundation

class CreditCard {
    public static func isValidCardNumber(cardNumber: String) -> Bool {
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

    // Card expiration date validation method
    public static func isExpiryValid(cardExpirationMonth: String, cardExpirationYear: String) -> Bool {
        let cardExpMonthValid = NSRegularExpression.regexCardNumberValidation(cardNumber: cardExpirationMonth)
        let cardExpYearValid = NSRegularExpression.regexCardNumberValidation(cardNumber: cardExpirationYear)
        if cardExpMonthValid && cardExpYearValid  {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .year], from: Date())
            let currentMonth = components.month ?? 1
            let currentYear = components.year ?? 2024

            let expMonthNumber = Int(cardExpirationMonth)!
            let expYearNumber = Int(cardExpirationYear)!
            if (expYearNumber > currentYear) || (expYearNumber == currentYear && expMonthNumber >= currentMonth) {
                return expMonthNumber >= 1 && expMonthNumber <= 12 && expYearNumber <= currentYear + 100
            }
        }
        return false
    }
    
    // Card cvn validation method
    public static func isCvnValid(creditCardCVN: String) -> Bool {
        let cvnLength = creditCardCVN.count
        return NSRegularExpression.regexCardNumberValidation(cardNumber: creditCardCVN) && (cvnLength == 3 || cvnLength == 4)
    }
    
    // Card cvn validation for card type method
    public static func isCvnValidForCardType(creditCardCVN: String, cardNumber: String) -> Bool {
        let cvnLength = creditCardCVN.count
        let isCardTypeAmex = isCardAmex(cardNumber: cardNumber)
        if NSRegularExpression.regexCardNumberValidation(cardNumber: creditCardCVN) {
            return isCardTypeAmex ? cvnLength == 4 : cvnLength == 3
        }
        return false
    }
    
    // Check 3DS EMV version
    public static func is3ds2Version(version: String?) -> Bool {
        if version != nil {
            let index = version!.index(version!.startIndex, offsetBy: 1)
            let currentMajorVersion = Int(version![..<index])!
            return currentMajorVersion >= 2
        }
        return false
    }
    
      // Get Card Type
      internal static func getCardType(cardNumber: String) -> CYBCardTypes {
          if cardNumber.hasPrefix("4") {
              if isCardVisaElectron(cardNumber: cardNumber) {
                  return CYBCardTypes.VISA_ELECTRON
              } else {
                  return CYBCardTypes.VISA
              }
          } else if isCardAmex(cardNumber: cardNumber) {
              return CYBCardTypes.AMEX
          } else if isCardMastercard(cardNumber: cardNumber) {
              return CYBCardTypes.MASTERCARD
          } else if isCardDiscover(cardNumber: cardNumber) {
              return CYBCardTypes.DISCOVER
          } else if isCardJCB(cardNumber: cardNumber) {
              return CYBCardTypes.JCB
          } else if isCardDankort(cardNumber: cardNumber) {
              return CYBCardTypes.DANKORT
          } else if isCardMaestro(cardNumber: cardNumber) {
              return CYBCardTypes.MAESTRO
          }
          return CYBCardTypes.UNKNOWN
      }
      
      // Validate Card for type Visa Electron
      private static func isCardVisaElectron(cardNumber: String) -> Bool {
          let startIndex = cardNumber.startIndex
          let shortRange = startIndex..<cardNumber.index(startIndex, offsetBy: 4)
          let longRange = startIndex..<cardNumber.index(startIndex, offsetBy: 6)
          return cardNumber.range(of: "4026", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                  cardNumber.range(of: "417500", options: .caseInsensitive, range: longRange, locale: nil) != nil ||
                  cardNumber.range(of: "4405", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                  cardNumber.range(of: "4508", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                  cardNumber.range(of: "4844", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                  cardNumber.range(of: "4913", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                  cardNumber.range(of: "4917", options: .caseInsensitive, range: shortRange, locale: nil) != nil
      }
      
      // Validate Card for type American Express
      private static func isCardAmex(cardNumber: String) -> Bool {
          let range = cardNumber.startIndex..<cardNumber.index(cardNumber.startIndex, offsetBy: 2)
          return cardNumber.range(of: "34", options: .caseInsensitive, range: range, locale: nil) != nil ||
                  cardNumber.range(of: "37", options: .caseInsensitive, range: range, locale: nil) != nil
      }
      
      // Validate Card for type Mastercard
      private static func isCardMastercard(cardNumber: String) -> Bool {
          if cardNumber.count > 2 {
              let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
              let startingNumber = Int(cardNumber[..<index])
              return startingNumber! >= 51 && startingNumber! <= 55
          }
          return false
      }
      
      // Validate Card for type Discover
      private static func isCardDiscover(cardNumber: String) -> Bool {
          if cardNumber.count > 6 {
              let firstStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 3)
              let firstStartingNumber = Int(cardNumber[..<firstStartingIndex])!
              let secondStartingIndex = cardNumber.index(cardNumber.startIndex, offsetBy: 6)
              let secondStartingNumber = Int(cardNumber[..<secondStartingIndex])!
              let startIndex = cardNumber.startIndex
              let shortRange = startIndex..<cardNumber.index(startIndex, offsetBy: 2)
              let longRange = startIndex..<cardNumber.index(startIndex, offsetBy: 4)

              return (firstStartingNumber >= 644 && firstStartingNumber <= 649) ||
                      (secondStartingNumber >= 622126 && secondStartingNumber <= 622925) ||
                      cardNumber.range(of: "65", options: .caseInsensitive, range: shortRange, locale: nil) != nil ||
                      cardNumber.range(of: "6011", options: .caseInsensitive, range: longRange, locale: nil) != nil
          }
          return false
      }
    
      // Validate Card for type JCB
      private static func isCardJCB(cardNumber: String) -> Bool {
          if cardNumber.count > 4 {
              let index = cardNumber.index(cardNumber.startIndex, offsetBy: 4)
              let startingNumber = Int(cardNumber[..<index])!
              return (startingNumber >= 3528 && startingNumber <= 3589) || cardNumber.hasPrefix("308800") || cardNumber.hasPrefix("333755") || cardNumber.hasPrefix("333700")
          }
          return false
      }
      
      // Validate Card for type Dankort
      private static func isCardDankort(cardNumber: String) -> Bool {
          let range = cardNumber.startIndex..<cardNumber.index(cardNumber.startIndex, offsetBy: 4)
          return cardNumber.range(of: "5019", options: .caseInsensitive, range: range, locale: nil) != nil
      }
      
      // Validate Card for type Maestro
      private static func isCardMaestro(cardNumber: String) -> Bool{
          if cardNumber.count > 2 {
              let index = cardNumber.index(cardNumber.startIndex, offsetBy: 2)
              let startingNumber = Int(cardNumber[..<index])!
              return startingNumber == 50 ||
                      (startingNumber >= 56 && startingNumber <= 64) ||
                      (startingNumber >= 66 && startingNumber <= 69)
          }
          return false
      }
}
