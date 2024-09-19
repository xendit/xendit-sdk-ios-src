//
//  XDTApiClient.swift
//  Xendit
//
//  Created by xendit on 28/10/20.
//

import Foundation

extension URLRequest {
    static func request(ur: URL) -> URLRequest {
        var request = URLRequest(url: ur)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    static func authorizedRequest(url: URL, method: String, publishableKey: String, extraHeaders: [String: String]?) -> URLRequest {
        var request = URLRequest.request(ur: url)
        let authorization = "Basic " + (publishableKey + ":").toBase64()
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue(XDTApiClient.CLIENT_TYPE, forHTTPHeaderField: "client-type")
        request.setValue(XDTApiClient.CLIENT_API_VERSION, forHTTPHeaderField: "client-version")
        request.setValue(XDTApiClient.CLIENT_IDENTIFIER, forHTTPHeaderField: "x-client-identifier")
        request.setValue(XDTApiClient.CLIENT_SDK_VERSION, forHTTPHeaderField: "x-client-sdk-version")
        
        if extraHeaders != nil {
            for (key, value) in extraHeaders! {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpMethod = method
        return request
    }
}

class XDTApiClient {
    
    internal static let CLIENT_TYPE = "SDK";
    internal static let CLIENT_API_VERSION = "2.0.0";
    internal static let CLIENT_IDENTIFIER = "Xendit iOS SDK";
    internal static let CLIENT_SDK_VERSION = "3.10.0";
    
    private static let WEBAPI_FLEX_BASE_URL = "https://sandbox.webapi.visa.com"
    
    private static let PRODUCTION_XENDIT_HOST = "api.xendit.co"
    private static let PRODUCTION_XENDIT_BASE_URL = "https://" + PRODUCTION_XENDIT_HOST
    
    private static let TOKEN_CREDENTIALS_PATH = "credit_card_tokenization_configuration"
    private static let CREATE_CREDIT_CARD_PATH = "v2/credit_card_tokens"
    private static let VERIFY_AUTHENTICATION_PATH = "credit_card_authentications/:authentication_id/verification"
    private static let JWT_PATH = "/credit_card_tokens/:token_id/jwt"
    private static let GET_3DS_RECOMMENDATION_URL = "/3ds_bin_recommendation"
    private static let CREDIT_CARD_PATH = "credit_card_tokens"
    private static let AUTHENTICATION_PATH = "authentications"
    private static let TOKENIZE_CARD_PATH = "cybersource/flex/v1/"
    
    private static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    static func tokenizeCardRequest(URL: URL, requestBody: [String:Any], completion: @escaping (_ : String?, _ : XenditError?) -> Void) {
        var request = URLRequest.request(ur: URL)
        request.httpMethod = "POST"
        
        Log.shared.logUrlRequest(prefix: "tokenizeCardRequest", request: request, requestBody: requestBody)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = bodyData
        } catch {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "tokenizeCardRequest", request: request, requestBody: requestBody, data: data, response: response, error: error)
            handleFlexResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handleError) in
                if parsedData != nil {
                    if let CYBToken = parsedData!["token"] as? String {
                        DispatchQueue.main.async {
                            completion(CYBToken, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handleError)
                    }
                }
            })
        }.resume()
    }
    
    static func createAuthenticationRequest(publishableKey: String, tokenId: String, bodyJson: [String:Any], extraHeader: [String:String], completion: @escaping (_: XenditAuthentication?, _: XenditError?) -> Void) {
        
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)!
        url.appendPathComponent(CREDIT_CARD_PATH)
        url.appendPathComponent(tokenId)
        url.appendPathComponent(AUTHENTICATION_PATH)
        
        var request = URLRequest.authorizedRequest(url: url, method: "POST", publishableKey: publishableKey, extraHeaders: extraHeader)
        
        Log.shared.logUrlRequest(prefix: "createAuthenticationRequest", request: request, requestBody: bodyJson)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "createAuthenticationRequest", request: request, requestBody: bodyJson, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let authentication = XenditAuthentication.init(response: parsedData!)
                    if authentication != nil {
                        DispatchQueue.main.async {
                            completion(authentication, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
    static func verifyAuthenticationRequest(publishableKey: String, authenticationId: String, bodyJson: [String:Any], extraHeader: [String:String]?, completion: @escaping (_: XenditAuthentication?, _: XenditError?) -> Void) {
        
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)!
        url.appendPathComponent(VERIFY_AUTHENTICATION_PATH.replacingOccurrences(of: ":authentication_id", with: authenticationId))
        
        var request = URLRequest.authorizedRequest(url: url, method: "POST", publishableKey: publishableKey, extraHeaders: extraHeader)
        
        Log.shared.logUrlRequest(prefix: "verifyAuthenticationRequest", request: request, requestBody: bodyJson)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "createAuthenticationRequest", request: request, requestBody: bodyJson, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let authentication = XenditAuthentication.init(response: parsedData!)
                    if authentication != nil {
                        DispatchQueue.main.async {
                            completion(authentication, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
    static func createTokenRequest(publishableKey: String, bodyJson: [String:Any], extraHeader: [String:String], completion: @escaping (_ : XenditAuthenticatedToken?, _ : XenditError?) -> Void) {
        
        var url = URL.init(string: PRODUCTION_XENDIT_BASE_URL)!
        url.appendPathComponent(CREATE_CREDIT_CARD_PATH)
        
        var request = URLRequest.authorizedRequest(url: url, method: "POST", publishableKey: publishableKey, extraHeaders: extraHeader)
        Log.shared.logUrlRequest(prefix: "createTokenRequest", request: request, requestBody: bodyJson)
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: bodyJson)
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "createTokenRequest", request: request, requestBody: bodyJson, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let token = XenditAuthenticatedToken.init(response: parsedData!)
                    if token != nil {
                        DispatchQueue.main.async {
                            completion(token, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
    public static func create3DSRecommendationRequest(publishableKey: String, tokenId: String, completion: @escaping (_ : Xendit3DSRecommendation?, _ : XenditError?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = PRODUCTION_XENDIT_HOST
        components.path = GET_3DS_RECOMMENDATION_URL
        components.queryItems = [
            URLQueryItem(name: "token_id", value: tokenId)
        ]
        let url = components.url!
        let request = URLRequest.authorizedRequest(url: url, method: "GET", publishableKey: publishableKey, extraHeaders: nil)
        
        Log.shared.logUrlRequest(prefix: "create3DSRecommendationRequest", request: request, requestBody: nil)
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "create3DSRecommendationRequest", request: request, requestBody: nil, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let token = Xendit3DSRecommendation.init(response: parsedData!)
                    if token != nil {
                        DispatchQueue.main.async {
                            completion(token, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Something unexpected happened, we are investigating this issue right now"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
    public static func getJWT(publishableKey: String, tokenId: String, requestBody: XenditJWTRequest, completion: @escaping (_ : XenditJWT?, _ : XenditError?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = PRODUCTION_XENDIT_HOST
        components.path = JWT_PATH.replacingOccurrences(of: ":token_id", with: tokenId)
        
        let url = components.url!
        var request = URLRequest.authorizedRequest(url: url, method: "POST", publishableKey: publishableKey, extraHeaders: nil)
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody.toJsonObject())
            request.httpBody = bodyData
        } catch _ {
            DispatchQueue.main.async {
                completion(nil, XenditError(errorCode: "JSON_SERIALIZATION_ERROR", message: "Failed to serialized JSON request data"))
            }
            return
        }
        
        Log.shared.logUrlRequest(prefix: "getJWT", request: request, requestBody: nil)
        
        session.dataTask(with: request) { (data, response, error) in
            Log.shared.logUrlResponse(prefix: "getJWT", request: request, requestBody: nil, data: data, response: response, error: error)
            handleResponse(data: data, urlResponse: response, error: error, handleCompletion: { (parsedData, handledError) in
                if parsedData != nil {
                    let jwt = XenditJWT.FromJson(response: parsedData)
                    DispatchQueue.main.async {
                        completion(jwt, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, handledError)
                    }
                }
            })
        }.resume()
    }
    
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
    
    private static var acceptableStatusCodes: [Int] { return Array(200..<300) }
}
