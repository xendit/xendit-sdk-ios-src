//
//  XenditStoreCVNRequest.swift
//  Xendit
//
//  Created by xendit on 9/3/23.
//

import Foundation

@objcMembers
@objc(XenditStoreCVNRequest) public class XenditStoreCVNRequest: XenditRetokenizationRequest {
    
    public override init (tokenId: String) {
        super.init(tokenId: tokenId)
    }
}
