//
//  Xendit3DSRecommendation.swift
//  Xendit
//
//  Created by Hakiem on 30/12/19.
//
//

import Foundation

@objcMembers
@objc(XEN3DSRecommendation) open class Xendit3DSRecommendation: NSObject {

    // Token id
    @objc(tokenID) open var tokenId: String!

    // Authentication url
    open var should3DS : Bool!

}

@objc extension Xendit3DSRecommendation {
    convenience init?(response: [String : Any]) {
        let tokenId = response["token_id"] as? String
        let should3DS = response["should_3ds"] as? Bool

        self.init()
        self.tokenId = tokenId
        self.should3DS = should3DS
    }
}


internal extension Xendit3DSRecommendation {
    convenience init(tokenId: String, should3DS: Bool) {
        self.init()
        self.tokenId = tokenId
        self.should3DS = should3DS
    }
}
