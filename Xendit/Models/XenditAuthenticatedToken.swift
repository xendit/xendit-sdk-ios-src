//
//  XenditAuthenticatedToken.swift
//  Xendit
//
//  Created by xendit on 27/10/20.
//

import Foundation

@objcMembers
@objc(XENAuthenticatedToken) open class XenditAuthenticatedToken: NSObject, Authenticatable {
    
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
    
    func getPayerAuthenticationUrl() -> String? {
        return authenticationURL;
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
    }
}
