//
//  LogSanitizer.swift
//  Xendit
//
//  Created by Vladimir Lyukov on 01/11/2018.
//

import Foundation


class LogSanitizer {
    func sanitizeRequestBody(_ requestBody: [String: Any]) -> Any {
        guard JSONSerialization.isValidJSONObject(requestBody) else {
            return "<invalid JSON>"
        }

        return recursiveSanitize(requestBody)
    }

    private func recursiveSanitize(_ payload: Any) -> Any {
        switch payload {
        case let value as [String: Any]:
            return value.reduce(into: [String: Any]()) { res, el in
                let (key, value) = el
                res[key] = recursiveSanitize(applyMaskRules(key, value))
            }
        case let value as [Any]:
            return value.map { recursiveSanitize($0) }
        default:
            return payload
        }
    }

    private func applyMaskRules(_ key: String, _ value: Any) -> Any {
        switch key {
        case "cardNumber": return mask(value, prefix: 4, suffix: 4)
        case "cardExpirationYear": return mask(value)
        case "cardExpirationMonth": return mask(value)
        case "keyId": return mask(value, prefix: 4, suffix: 4)

        case "card_cvn": return mask(value)
        case "credit_card_token": return mask(value, prefix: 4, suffix: 4)
        default: return value
        }
    }

    private func mask(_ value: Any, prefix: Int = 0, suffix: Int = 0) -> String {
        switch value {
        case let value as [Any]: return "<Array[\(value.count)]>"
        case let value as [String: Any]: return "<Dictionary[\(value.count)]>"
        case let value as String: return value.mask("*", prefix: prefix, suffix: suffix)
        case let value as CustomStringConvertible: return value.description.mask("*", prefix: prefix, suffix: suffix)
        default: return "***"
        }
    }
}
