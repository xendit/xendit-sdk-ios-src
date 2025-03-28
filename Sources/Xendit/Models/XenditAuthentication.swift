//
//  XenditAuthentication.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/4/17.
//
//

import Foundation

@objcMembers
@objc(XENAuthentication) open class XenditAuthentication: NSObject, Authenticatable, Codable, JsonSerializable, @unchecked Sendable {

    // Authentication id
    @objc(authenticationID) open var id: String!

    // Authentication status
    open var status: String!
    
    // Credit card token id
    open var tokenId: String?

    // Authentication url
    open var authenticationURL: String?
    
    open var authenticationTransactionId: String?
    
    open var requestPayload: String?
    
    open var maskedCardNumber: String?
    
    open var cardInfo: XenditCardMetadata?
    
    // 3DS version
    open var threedsVersion : String?
    
    // Failure reason
    open var failureReason : String?
    
    func getPayerAuthenticationUrl() -> String? {
        return authenticationURL
    }
    
    func toJsonObject() -> [String : any Sendable] {
        var json: [String: any Sendable] = [:]
        if id != nil { json["id"] = id }
        if status != nil { json["status"] = status }
        if authenticationURL != nil { json["authentication_url"] = authenticationURL }
        if authenticationTransactionId != nil { json["authentication_transaction_id"] = authenticationTransactionId }
        if tokenId != nil { json["credit_card_token_id"] = tokenId }
        if requestPayload != nil { json["pa_res"] = requestPayload }
        if maskedCardNumber != nil { json["masked_card_number"] = maskedCardNumber }
        if cardInfo != nil { json["card_info"] = cardInfo?.toJsonObject() }
        if threedsVersion != nil { json["threeds_version"] = threedsVersion }
        if failureReason != nil { json["failure_reason"] = failureReason }
        return json
    }

}

@objc extension XenditAuthentication {
    convenience init?(response: [String : Any]) {
        let id = response["id"] as? String
        let status = response["status"] as? String

        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = (response["payer_authentication_url"] as? String)
        self.authenticationTransactionId = response["authentication_transaction_id"] as? String
        self.requestPayload = response["pa_req"] as? String
        self.maskedCardNumber = response["masked_card_number"] as? String
        self.tokenId = response["credit_card_token_id"] as? String
        self.cardInfo = XenditCardMetadata(response: response["card_info"] as? [String: Any])
        self.threedsVersion = response["threeds_version"] as? String
        self.failureReason = response["failure_reason"] as? String
    }
}


internal extension XenditAuthentication {
    convenience init(id: String, status: String, authenticationURL: String?) {
        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = authenticationURL
    }
    
    convenience init(id: String, status: String, maskedCardNumber: String?, cardInfo: XenditCardMetadata?) {
        self.init()
        self.id = id
        self.status = status
        self.maskedCardNumber = maskedCardNumber
        self.cardInfo = cardInfo
    }
}
