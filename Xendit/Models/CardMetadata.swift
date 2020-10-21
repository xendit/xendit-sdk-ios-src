//
//  CardMetadata.swift
//  Xendit
//
//  Created by xendit on 21/10/20.
//

import Foundation

@objcMembers
@objc(XENCardMetadata) open class CardMetadata: NSObject {
    
    // Issuing bank name
    open var bank: String?
    
    // Card country
    open var countryCode: String?
    
    // Card type
    open var type: String?
    
    // Card brand
    open var brand: String?
    
    // Card art url
    open var cardArtUrl: String?

    public override init() {
    }
}

@objc extension CardMetadata {
    convenience init?(response: [String : Any]) {
        self.init()
        
        self.bank = (response["bank"] as? String)
        self.countryCode = (response["country_code"] as? String)
        self.type = (response["type"] as? String)
        self.brand = (response["brand"] as? String)
        self.cardArtUrl = (response["card_art_url"] as? String)
        
    }
}
