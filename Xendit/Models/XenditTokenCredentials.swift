//
//  XenditTokenCredentials.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation

@objc(XENTokenCredentials) class XenditTokenCredentials: NSObject {
    
    // Flex api key
    var flexApiKey : String!
    
    // Tokenization auth key id
    var authKeyId : String!
    
}

extension XenditTokenCredentials {
    convenience init?(dictionary: [String : Any]) {
        guard let flexApiKey = dictionary["flex_api_key"] as? String,
               let authKeyId = dictionary["tokenization_auth_key_id"] as? String else { return nil }
        self.init()
        self.flexApiKey = flexApiKey
        self.authKeyId = authKeyId
    }
}
