//
//  XenditCCToken.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/22/17.
//
//

import Foundation

@objc(XENCCToken) open class XenditCCToken: NSObject {
    
    // Token id
    @objc(tokenID) open var id: String!
    
    // Token status
    open var status : String!
    
    // Authentication url
    open var authenticationURL : String?
    
}

extension XenditCCToken {
    convenience init?(response: [String : Any]) {
        guard let id = response["id"] as? String,
            let status = response["status"] as? String else { return nil }
        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = (response["payer_authentication_url"] as? String)
    }
}
