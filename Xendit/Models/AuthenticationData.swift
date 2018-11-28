//
//  AuthenticationData.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/5/17.
//
//

import Foundation

@objcMembers
@objc(XENAuthenticationData) open class AuthenticationData: NSObject {

    // Token id value
    open var tokenId: String!

    // Card verification number (CVN) value
    open var cardCvn: String!

    // Card transaction amount
    open var amount: NSNumber!
    
}

