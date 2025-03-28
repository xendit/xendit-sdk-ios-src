//
//  XenditJWT.swift
//  Xendit
//
//  Created by xendit on 30/10/20.
//

import Foundation

class XenditJWT: JsonDeserializable {
    public var jwt: String?
    public var environment: String?
    
    static func FromJson(response: [String : any Sendable]?) -> XenditJWT {
        let jwt = XenditJWT()
        if response == nil {
            return jwt
        }
        jwt.jwt = response!["jwt"] as? String
        jwt.environment = response!["environment"] as? String
        return jwt
    }
}
