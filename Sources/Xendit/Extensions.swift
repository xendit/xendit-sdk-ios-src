//
//  Extensions.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation

    // MARK: - NSRegularExpression
extension NSRegularExpression {
    static func regexCardNumberValidation(cardNumber: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^\\d+$", options: .caseInsensitive)
        let matches = regex.matches(in: cardNumber, options: [], range: NSRange(location: 0, length: cardNumber.utf16.count))
        return matches.count > 0
    }
}

    // MARK: - String

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    // Masks symbols in string, leaving only `prefix` unmasked symbols from beginning of string and `suffix` symbols at the end of string
    func mask(_ symbol: String = "*", prefix: Int = 0, suffix: Int = 0) -> String {
        guard self.count > prefix + suffix else {
            return self
        }
        let mask = String(repeating: symbol, count: max(0, self.count - prefix - suffix))
        return "\(self.prefix(prefix))\(mask)\(self.suffix(suffix))"
    }
}
