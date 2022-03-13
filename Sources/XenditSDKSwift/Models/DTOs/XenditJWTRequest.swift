//
//  XenditJWTRequest.swift
//  Xendit
//
//  Created by xendit on 05/11/20.
//

import Foundation

public class XenditJWTRequest: JsonSerializable {
    open var amount: NSNumber = 0.0
    open var currency: String?
    open var midLabel: String?
    open var customer: XenditCustomer?
    
    convenience init(amount: NSNumber) {
        self.init()
        self.amount = amount
    }
    
    func toJsonObject() -> [String : Any] {
        var jsonObject: [String: Any] = [
            "amount": self.amount,
        ]
        if self.currency != nil { jsonObject["currency"] = self.currency }
        if self.midLabel != nil { jsonObject["mid_label"] = self.midLabel }
        if self.customer != nil {
            jsonObject["customer"] = customer?.toJsonObject()
        }
        return jsonObject
        
    }
}
