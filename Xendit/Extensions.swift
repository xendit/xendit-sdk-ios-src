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
    
    static func prepareCreateTokenBody(cardToken: String, cardData: CardData) -> [String: Any] {
        let json: [String: Any] = ["amount" : cardData.amount.intValue, "card_cvn" : cardData.cardCvn, "credit_card_token" : cardToken, "is_authentication_bundled" : "true"]
        return json
    }

    static func prepareCreateAuthenticationBody(authenticationData: AuthenticationData) -> [String: Any] {
        let json: [String: Any] = ["amount" : authenticationData.amount.intValue, "card_cvn" : authenticationData.cardCvn]
        return json
    }
    
    static func isProductionPublishableKey() -> Bool {
        let normalizeKey = publishableKey?.uppercased()
        return (normalizeKey?.contains("PRODUCTION"))!
    }
    
    private static var acceptableStatusCodes: [Int] { return Array(200..<300) }
    
    static func handleResponse(data: Data?, urlResponse: URLResponse?, error: Error?, handleCompletion: @escaping (_ : [String : Any]?, _ : XenditError?) -> Void) {
        if error != nil {
            handleCompletion(nil, XenditError.requestFailedWithError(error: error!))
        } else if let httpRespose = urlResponse as? HTTPURLResponse {
            if acceptableStatusCodes.contains(httpRespose.statusCode) {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    handleCompletion(parsedData, nil)
                } catch let error {
                    handleCompletion(nil, XenditError.jsonEncodingFailed(error: error))
                }
            } else {
                var message = ""
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    if let string = parsedData?["message"] {
                        message = string as! String
                    }
                    if let responseStatus = parsedData?["responseStatus"] as? [String : Any] {
                        if let msg =  responseStatus["message"]  {
                            message = msg as! String
                        }
                    }
                } catch { }
                let description = String(format:"Request failed with code: %d, message: %@", httpRespose.statusCode, message)
                handleCompletion(nil, XenditError.requestFailedWithDescription(description: description))
            }
        }
    }
    
    internal static func handleCreateCardToken(fromViewController: UIViewController, token: XenditCCToken?, error: XenditError?, completion:@escaping (_ : XenditCCToken?, _ : Error?) -> Void) {
        let status = token?.status
        if status != nil {
            if status == "APPROVED" || status == "VERIFIED" {
                completion(token, nil)
            } else if status == "IN_REVIEW" && token?.authenticationURL != nil {
                let webViewController = WebViewController(URL: (token?.authenticationURL)!)
                webViewController.token = token
                webViewController.authenticateCompletion = { (token, error) -> Void in
                    webViewController.dismiss(animated: true, completion: nil)
                    completion(token, error)
                }
                DispatchQueue.main.async {
                    fromViewController.present(webViewController, animated: true, completion: nil)
                }
            } else if status == "FRAUD" ||  status == "FAILED" {
                let description = String(format: "Failed create authentication with status: %@", status!)
                completion(nil, XenditError.requestFailedWithDescription(description: description))
            } else {
                let description = String(format: "Something went wrong, XenditCCToken status: %@, XenditCCToken id: %@", status!, (token?.id)!)
                completion(nil, XenditError.requestFailedWithDescription(description: description))
            }
        } else if error != nil {
            completion(nil, error)
        } else {
            completion(nil, XenditError.requestFailedWithDescription(description: "Failed create credit card token"))
        }
    }

    internal static func handleCreateAuthentication(fromViewController: UIViewController, authentication: XenditAuthentication?, error: XenditError?, completion:@escaping (_ : XenditAuthentication?, _ : Error?) -> Void) {
        let status = authentication?.status

        if status != nil {
            if status == "APPROVED" || status == "VERIFIED" {
                completion(authentication, nil)
            } else if status == "IN_REVIEW" && authentication?.authenticationURL != nil {
                let webViewController = AuthenticationWebViewController(URL: (authentication?.authenticationURL)!)
                webViewController.authentication = authentication
                webViewController.authenticateCompletion = { (updatedAuthentication, error) -> Void in
                    webViewController.dismiss(animated: true, completion: nil)
                    completion(updatedAuthentication, error)
                }
                DispatchQueue.main.async {
                    fromViewController.present(webViewController, animated: true, completion: nil)
                }
            } else if status == "FRAUD" ||  status == "FAILED" {
                let description = String(format: "Failed create authentication with status: %@", status!)
                completion(nil, XenditError.requestFailedWithDescription(description: description))
            } else {
                let description = String(format: "Something went wrong, XenditCCToken status: %@, XenditAuthentication id: %@", status!, (authentication?.id)!)
                completion(nil, XenditError.requestFailedWithDescription(description: description))
            }
        } else if error != nil {
            completion(nil, error)
        } else {
            completion(nil, XenditError.requestFailedWithDescription(description: "Failed create credit card token"))
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
