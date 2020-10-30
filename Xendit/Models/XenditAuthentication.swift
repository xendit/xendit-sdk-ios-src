//
//  XenditAuthentication.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/4/17.
//
//

import Foundation

@objcMembers
@objc(XENAuthentication) open class XenditAuthentication: NSObject, Authenticatable {

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
    
    open var metadata: XenditCardMetadata?
    
    
    func getPayerAuthenticationUrl() -> String? {
        return authenticationURL
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
        self.metadata = XenditCardMetadata(response: response["metadata"] as? [String: Any])
    }
}


internal extension XenditAuthentication {
    convenience init(id: String, status: String, authenticationURL: String?) {
        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = authenticationURL
    }
    
    convenience init(id: String, status: String, maskedCardNumber: String?, metadata: XenditCardMetadata?) {
        self.init()
        self.id = id
        self.status = status
        self.maskedCardNumber = maskedCardNumber
        self.metadata = metadata
    }
}
