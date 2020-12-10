//
//  CardMetadata.swift
//  Xendit
//
//  Created by xendit on 21/10/20.
//

import Foundation

@objcMembers
@objc(XENCardMetadata) open class XenditCardMetadata: NSObject {
    
    // Issuing bank name
    open var bank: String?
    
    // Card country
    open var country: String?
    
    // Card type
    open var type: String?
    
    // Card brand
    open var brand: String?
    
    // Card art url
    open var cardArtUrl: String?

    public override init() {
    }
}

@objc extension XenditCardMetadata {
    convenience init?(response: [String : Any]?) {
        self.init()
        guard response != nil else {
            return
        }
        self.bank = (response!["bank"] as? String)
        self.country = (response!["country_code"] as? String)
        self.type = (response!["type"] as? String)
        self.brand = (response!["brand"] as? String)
        self.cardArtUrl = (response!["card_art_url"] as? String)
        
    }
}
