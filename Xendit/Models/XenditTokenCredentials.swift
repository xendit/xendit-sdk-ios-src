//
//  XenditTokenCredentials.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation

@objcMembers
@objc(XENTokenCredentials) class XenditTokenCredentials: NSObject {
    
    // Flex api key
    var flexApiKey : String!
    
    // Tokenization auth key id
    var authKeyId : String!

    // Flex URLs
    var flexProductionURL : String!
    var flexDevelopmentURL : String!
    
}

@objc extension XenditTokenCredentials {
    convenience init?(dictionary: [String : Any]) {
        let flexApiKey = dictionary["flex_api_key"] as? String
        let authKeyId = dictionary["tokenization_auth_key_id"] as? String
        let flexProductionURL = dictionary["flex_production_url"] as? String
        let flexDevelopmentURL = dictionary["flex_development_url"] as? String


        self.init()
        self.flexApiKey = flexApiKey
        self.authKeyId = authKeyId
        self.flexProductionURL = flexProductionURL
        self.flexDevelopmentURL = flexDevelopmentURL
    }
}
