//
//  CardMetadata.swift
//  Xendit
//
//  Created by xendit on 21/10/20.
//

import Foundation

@objcMembers
@objc(XENCardMetadata) open class XenditCardMetadata: NSObject, Codable, JsonSerializable {

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
    
    // Card fingerprint
    open var fingerprint: String?

    public override init() {
    }
    
    func toJsonObject() -> [String : Any] {
        var json: [String: Any] = [:]
        if bank != nil { json["bank"] = bank }
        if country != nil { json["country"] = country }
        if type != nil { json["type"] = type }
        if brand != nil { json["brand"] = brand }
        if cardArtUrl != nil { json["card_art_url"] = cardArtUrl }
        if fingerprint != nil { json["fingerprint"] = fingerprint }
        return json
    }
    
}

@objc extension XenditCardMetadata {
    convenience init?(response: [String : Any]?) {
        self.init()
        guard response != nil else {
            return
        }
        self.bank = (response!["bank"] as? String)
        self.country = (response!["country"] as? String)
        self.type = (response!["type"] as? String)
        self.brand = (response!["brand"] as? String)
        self.cardArtUrl = (response!["card_art_url"] as? String)
        self.fingerprint = (response!["fingerprint"] as? String)
    }
}
