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
    public var province: String?
    public var state: String?
    public var postalCode: String?
    
    public init() {}

    static func FromJson(response: [String: Any]?) -> XenditAddress {
        let xenditAddress = XenditAddress()
        if response == nil {
            return xenditAddress
        }
        xenditAddress.country = response!["country"] as? String
        xenditAddress.streetLine1 = response!["street_line_1"] as? String
        xenditAddress.streetLine2 = response!["street_line_2"] as? String
        xenditAddress.city = response!["city"] as? String
        xenditAddress.province = response!["province"] as? String
        xenditAddress.state = response!["state"] as? String
        xenditAddress.postalCode = response!["postal_code"] as? String
        
        return xenditAddress
    }
    
    func toJsonObject() -> [String: Any] {
        var json: [String: Any] = [:]
        if country != nil { json["country"] = country }
        if streetLine1 != nil { json["street_line_1"] = streetLine1 }
        if streetLine2 != nil { json["street_line_2"] = streetLine2 }
        if city != nil { json["city"] = city }
        if province != nil { json["province"] = province }
        if state != nil { json["state"] = state }
        if postalCode != nil { json["postal_code"] = postalCode }
        return json
    }
    
}
