//
//  XenditRetokenizationRequest.swift
//  Xendit
//
//  Created by xendit on 4/12/22.
//
import Foundation

@objcMembers
@objc(XenditRetokenizationRequest) public class XenditRetokenizationRequest: NSObject, JsonSerializable {
    
    public var tokenId: String
    public var cardCvn: String?
    public var billingDetails: XenditBillingDetails?
    public var customer: XenditCustomer?
    
    public init (tokenId: String) {
        self.tokenId = tokenId
    }
    
    func toJsonObject() -> [String : Any] {
        var json: [String: Any] = [
            "token_id": tokenId
        ]
        
        if (cardCvn != nil) {
            json["card_cvn"] = cardCvn
        }
        
        if (billingDetails != nil) {
            json["billing_details"] = billingDetails!.toJsonObject()
        }
        
        if (customer != nil) {
            json["customer"] = customer!.toJsonObject()
        }
        
        return json
    }
}
