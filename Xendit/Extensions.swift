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

    // MARK: - Xendit

extension Xendit {
    static func prepareCreateTokenBody(cardData: CardData, shouldAuthenticate: Bool) -> [String: Any] {
        var card_json: [String: String] = [
            "account_number": cardData.cardNumber,
            "exp_month": cardData.cardExpMonth,
            "exp_year": cardData.cardExpYear,
        ]
        
        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            card_json["cvn"] = cardData.cardCvn
        }
        
        var json: [String: Any] = [
            "should_authenticate": shouldAuthenticate,
            "card_data": card_json,
            "is_single_use": !cardData.isMultipleUse
        ]

        if (!cardData.isMultipleUse) {
            json["amount"] = cardData.amount;
        }
        
        return json
    }

    static func prepareCreateAuthenticationBody(authenticationData: AuthenticationData) -> [String: Any] {
        let json: [String: Any] = ["amount" : authenticationData.amount.intValue]
        return json
    }
    
    static func isProductionPublishableKey() -> Bool {
        let normalizeKey = publishableKey?.uppercased()
        return (normalizeKey?.contains("PRODUCTION"))!
    }
    
    private static var acceptableStatusCodes: [Int] { return Array(200..<300) }
    
    static func handleResponse(data: Data?, urlResponse: URLResponse?, error: Error?, handleCompletion: @escaping (_ : [String : Any]?, _ : XenditError?) -> Void) {
        if let error = error {
            handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: error.localizedDescription))
        } else if let httpResponse = urlResponse as? HTTPURLResponse {
            if acceptableStatusCodes.contains(httpResponse.statusCode) {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    handleCompletion(parsedData, nil)
                } catch {
                    handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
                }
            } else {
                if let parsedData = try? JSONSerialization.jsonObject(with: data!, options: []),
                        let parsedDict = parsedData as? [String : Any],
                        let errorCode = parsedDict["error_code"] as? String,
                        let message = parsedDict["message"] as? String {
                    handleCompletion(nil, XenditError(errorCode: errorCode, message: message))
                } else {
                    handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
                }
            }
        }
    }

    static func handleFlexResponse(data: Data?, urlResponse: URLResponse?, error: Error?, handleCompletion: @escaping (_ : [String : Any]?, _ : XenditError?) -> Void) {
        if let error = error {
            handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: error.localizedDescription))
        } else if let httpResponse = urlResponse as? HTTPURLResponse {
            if acceptableStatusCodes.contains(httpResponse.statusCode) {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    handleCompletion(parsedData, nil)
                } catch {
                    handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
                }
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]

                    if let responseStatus = parsedData?["responseStatus"] as? [String: Any],
                            let reason = responseStatus["reason"] as? String,
                            let message = responseStatus["message"] as? String {
                        if (reason == "VALIDATION_ERROR") {
                            handleCompletion(nil, XenditError(errorCode: "VALIDATION_ERROR", message: message))
                        } else {
                            handleCompletion(nil, XenditError(errorCode: "TOKENIZATION_ERROR", message: message))
                        }
                    } else {
                        handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                    }
                }
                catch _ {
                    handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
                }
            }
        }
    }
    
    internal static func handleCreateCardToken(fromViewController: UIViewController, token: XenditCCToken?, error: XenditError?, completion:@escaping (_ : XenditCCToken?, _ : XenditError?) -> Void) {
        if let error = error {
            // handle error message
            if error.errorCode == "INVALID_USER_ID" {
                error.message = error.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
            }
            return completion(nil, error)
        }

        let status = token?.status
        
        if status != nil {
            if status == "IN_REVIEW", let authenticationURL = token?.authenticationURL {
                cardAuthenticationProvider.authenticate(
                    fromViewController: fromViewController,
                    URL: authenticationURL,
                    token: token!,
                    completion: completion
                )
            } else {
                completion(token, nil)
            }
        } else {
            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
        }
    }

    internal static func handleCreateAuthentication(fromViewController: UIViewController, authentication: XenditAuthentication?, error: XenditError?, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        if (error != nil) {
            // handle error message
            if error!.errorCode == "INVALID_USER_ID" {
                error!.message = error!.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
            }
            completion(nil, error);
            return
        }
        
        let status = authentication?.status

        if status != nil {
            if status == "IN_REVIEW", let authenticationURL = authentication?.authenticationURL {
                authenticationProvider.authenticate(
                    fromViewController: fromViewController,
                    URL: authenticationURL,
                    authentication: authentication!,
                    completion: completion
                )
            } else {
                completion(authentication, nil)
            }
        } else {
            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
        }
    }
}

    // MARK: - URLRequest

extension URLRequest {
    static func request(ur: URL) -> URLRequest {
        var request = URLRequest(url: ur)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    static func authorizationRequest(url: URL, publishableKey: String) -> URLRequest {
        var request = URLRequest.request(ur: url)
        let authorization = "Basic " + (publishableKey + ":").toBase64()
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        return request
    }
}
