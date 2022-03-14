//
//  Address.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

public class XenditAddress: Jsonable {
    
    public var country: String?
    public var streetLine1: String?
    public var streetLine2: String?
    public var city: String?
    public var provinceState: String?
    public var postalCode: String?
    public var category: String?
    
    public init() {}

    static func FromJson(response: [String: Any]?) -> XenditAddress {
        let xenditAddress = XenditAddress()
        if response == nil {
            return xenditAddress
        }
        xenditAddress.country = response!["country"] as? String
        xenditAddress.streetLine1 = response!["street_line1"] as? String
        xenditAddress.streetLine2 = response!["street_line2"] as? String
        xenditAddress.city = response!["city"] as? String
        xenditAddress.provinceState = response!["province_state"] as? String
        xenditAddress.postalCode = response!["postal_code"] as? String
        xenditAddress.category = response!["category"] as? String
        
        return xenditAddress
    }
    
    func toJsonObject() -> [String: Any] {
        var json: [String: Any] = [:]
        if country != nil { json["country"] = country }
        if streetLine1 != nil { json["street_line1"] = streetLine1 }
        if streetLine2 != nil { json["street_line2"] = streetLine2 }
        if city != nil { json["city"] = city }
        if provinceState != nil { json["province_state"] = provinceState }
        if postalCode != nil { json["postal_code"] = postalCode }
        if category != nil { json["category"] = category }
        return json
    }
    
}
