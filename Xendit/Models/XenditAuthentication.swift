//
//  XenditAuthentication.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/4/17.
//
//

import Foundation

@objcMembers
@objc(XENAuthentication) open class XenditAuthentication: NSObject {

    // Token id
    @objc(authenticationID) open var id: String!

    // Token status
    open var status : String!

    // Authentication url
    open var authenticationURL : String?

}

@objc extension XenditAuthentication {
    convenience init?(response: [String : Any]) {
        let id = response["id"] as? String
        let status = response["status"] as? String

        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = (response["payer_authentication_url"] as? String)
    }
}


internal extension XenditAuthentication {
    convenience init(id: String, status: String, authenticationURL: String?) {
        self.init()
        self.id = id
        self.status = status
        self.authenticationURL = authenticationURL
    }
}
