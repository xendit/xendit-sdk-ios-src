//
//  XenditCCToken.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/22/17.
//
//

import Foundation

@objcMembers
@objc(XENCCToken) open class XenditCCToken: NSObject {
    
    // Token id
    @objc(tokenID) open var id: String!
    
    // Token status
    open var status : String!

    open var authenticationId : String!
    
    // Authentication redirect url
    open var authenticationURL : String?
    
    // Masked card number
    open var maskedCardNumber : String?

    // 3DS recommendation value
    open var should3DS : Bool?
    
    open var metadata : XenditCardMetadata?
    
}

@objc extension XenditCCToken {
    convenience init?(response: [String : Any]) {
        guard let id = response["id"] as? String else { return nil }
        guard let status = response["status"] as? String else { return nil }

        self.init()
        
        self.id = id
        self.status = status
        self.authenticationId = (response["authentication_id"] as? String)
        self.authenticationURL = (response["payer_authentication_url"] as? String)
        self.maskedCardNumber = (response["masked_card_number"] as? String)
        
        if (response["metadata"] != nil) {
            self.metadata = XenditCardMetadata(response: response["metadata"] as? [String : Any])
        }
        
    }
}

@objc extension XenditCCToken {
    convenience init?(authenticatedToken: XenditAuthenticatedToken) {
        self.init()
        
        self.id = authenticatedToken.id
        self.status = authenticatedToken.status
        self.authenticationId = authenticatedToken.authenticationId
        self.authenticationURL = authenticatedToken.authenticationURL
        self.maskedCardNumber = authenticatedToken.maskedCardNumber
        self.metadata = authenticatedToken.metadata
    }
}

@objc extension XenditCCToken {
    convenience init?(tokenId: String, authentication: XenditAuthentication) {
        self.init()
        
        self.id = tokenId
        self.status = authentication.status
        self.authenticationId = authentication.id
        self.authenticationURL = authentication.authenticationURL
        self.maskedCardNumber = authentication.maskedCardNumber
        self.metadata = authentication.metadata
    }
}

internal extension XenditCCToken {
    convenience init(id: String, status: String, authenticationId: String, authenticationURL: String?, maskedCardNumber: String?) {
        self.init()
        self.id = id
        self.status = status
        self.authenticationId = authenticationId
        self.authenticationURL = authenticationURL
        self.maskedCardNumber = maskedCardNumber
    }
}

internal extension XenditCCToken {
    convenience init(token: XenditCCToken, should3DS: Bool?) {
        self.init()
        self.id = token.id
        self.status = token.status
        self.authenticationId = token.authenticationId
        self.authenticationURL = token.authenticationURL
        self.maskedCardNumber = token.maskedCardNumber
        self.metadata = token.metadata
        self.should3DS = should3DS
    }
}
