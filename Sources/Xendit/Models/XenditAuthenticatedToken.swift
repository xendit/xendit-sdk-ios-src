//
//  XenditAuthenticatedToken.swift
//  Xendit
//
//  Created by xendit on 27/10/20.
//

import Foundation

@objcMembers
@objc(XENAuthenticatedToken) open class XenditAuthenticatedToken: NSObject, Authenticatable, Codable, JsonSerializable, @unchecked Sendable {
    
    // Token id
    @objc(tokenID) open var id: String!
    
    // Token status
    open var status : String!

    // Authentication id
    open var authenticationId : String?
    
    // Authentication url
    open var authenticationURL : String?
    
    // Masked card number
    open var maskedCardNumber : String?
    
    // JWT token for EMV 3DS
    open var jwt : String?
    
    // Token environment
    open var environment : String?
    
    // 3DS version
    open var threedsVersion : String?
    
    // Credit card metadata
    open var cardInfo : XenditCardMetadata?
    
    // Failure reason
    open var failureReason : String?
    
    func getPayerAuthenticationUrl() -> String? {
        return authenticationURL;
    }
    
    func toJsonObject() -> [String : any Sendable] {
        var json: [String: any Sendable] = [:]
        if id != nil { json["id"] = id }
        if status != nil { json["status"] = status }
        if authenticationURL != nil { json["authentication_url"] = authenticationURL }
        if maskedCardNumber != nil { json["masked_card_number"] = maskedCardNumber }
        if jwt != nil { json["jwt"] = jwt }
        if environment != nil { json["environment"] = environment }
        if threedsVersion != nil { json["threeds_version"] = threedsVersion }
        if cardInfo != nil { json["card_info"] = cardInfo?.toJsonObject() }
        if failureReason != nil { json["failure_reason"] = failureReason }
        return json
    }
    
}

@objc extension XenditAuthenticatedToken {
    convenience init?(response: [String : Any]) {
        self.init()
        self.id = response["id"] as? String
        self.authenticationId = response["authentication_id"] as? String
        self.status = response["status"] as? String
        self.authenticationURL = response["payer_authentication_url"] as? String
        self.maskedCardNumber = response["masked_card_number"] as? String
        self.jwt = response["jwt"] as? String
        self.environment = response["environment"] as? String
        self.threedsVersion = response["threeds_version"] as? String
        self.cardInfo = XenditCardMetadata(response: response["card_info"] as? [String : Any])
        self.failureReason = response["failure_reason"] as? String
    }
}
