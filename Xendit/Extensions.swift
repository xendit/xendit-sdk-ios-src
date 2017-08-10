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
}

    // MARK: - Xendit

extension Xendit {
    static func prepareTokenizeCreditCardBody(cardData: CardData, tokenCredentials: XenditTokenCredentials, cardType: String) -> [String: Any] {
        let json: [String: Any] = ["keyId": tokenCredentials.authKeyId,
                                   "cardInfo": ["cardNumber" : cardData.cardNumber, "cardExpirationMonth" : cardData.cardExpMonth,
                                                "cardExpirationYear" : cardData.cardExpYear, "cardType" : cardType]]
        return json
    }
    
    static func prepareCreateTokenBody(cardToken: String, cardData: CardData, shouldAuthenticate: Bool) -> [String: Any] {
        var json: [String: Any] = [
            "amount" : cardData.amount.intValue,
            "credit_card_token" : cardToken,
            "is_authentication_bundled" : !cardData.isMultipleUse,
            "should_authenticate": shouldAuthenticate
        ]

        if cardData.cardCvn != nil && cardData.cardCvn != "" {
            json["card_cvn"] = cardData.cardCvn
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
        if error != nil {
            handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: error!.localizedDescription))
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
                    let errorCode = parsedData?["error_code"] as! String
                    let message = parsedData?["message"] as! String

                    handleCompletion(nil, XenditError(errorCode: errorCode, message: message))
                }
                catch {
                    handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
                }
            }
        }
    }

    static func handleFlexResponse(data: Data?, urlResponse: URLResponse?, error: Error?, handleCompletion: @escaping (_ : [String : Any]?, _ : XenditError?) -> Void) {
        if error != nil {
            handleCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: error!.localizedDescription))
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

                    if let responseStatus = parsedData?["responseStatus"] as? [String : Any] {
                        let reason = responseStatus["reason"] as! String
                        let message = responseStatus["message"] as! String

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
        if (error != nil) {
            return completion(nil, error);
        }

        let status = token?.status
        
        if status != nil {
            if status == "IN_REVIEW" && token?.authenticationURL != nil {
                let webViewController = WebViewController(URL: (token?.authenticationURL)!)
                
                webViewController.token = token
                webViewController.authenticateCompletion = { (token, error) -> Void in
                    webViewController.dismiss(animated: true, completion: nil)
                    completion(token, error)
                }
                
                DispatchQueue.main.async {
                    fromViewController.present(webViewController, animated: true, completion: nil)
                }
            } else {
                completion(token, nil)
            }
        } else {
            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
        }
    }

    internal static func handleCreateAuthentication(fromViewController: UIViewController, authentication: XenditAuthentication?, error: XenditError?, completion:@escaping (_ : XenditAuthentication?, _ : XenditError?) -> Void) {
        if (error != nil) {
            completion(nil, error);
        }
        
        let status = authentication?.status

        if status != nil {
            if status == "IN_REVIEW" && authentication?.authenticationURL != nil {
                let webViewController = AuthenticationWebViewController(URL: (authentication?.authenticationURL)!)
                webViewController.authentication = authentication
                webViewController.authenticateCompletion = { (updatedAuthentication, error) -> Void in
                    webViewController.dismiss(animated: true, completion: nil)
                    completion(updatedAuthentication, error)
                }
                DispatchQueue.main.async {
                    fromViewController.present(webViewController, animated: true, completion: nil)
                }
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
