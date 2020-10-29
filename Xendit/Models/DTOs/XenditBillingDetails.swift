//
//  BillingDetails.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

public class XenditBillingDetails: Jsonable {
    
    public var givenNames: String?
    public var middleName: String?
    public var surname: String?
    public var email: String?
    public var mobileNumber: String?
    public var phoneNumber: String?
    public var address: XenditAddress?
    
    public init() {}
    
    func toJsonObject() -> [String : Any] {
        var json: [String: Any] = [:]
        if givenNames != nil { json["given_names"] = givenNames }
        if middleName != nil { json["middle_name"] = middleName }
        if surname != nil { json["surname"] = surname }
        if email != nil { json["email"] = email }
        if mobileNumber != nil { json["mobile_number"] = mobileNumber }
        if phoneNumber != nil { json["phone_number"] = phoneNumber }
        if address != nil { json["address"] = address!.toJsonObject() }
        return json
    }
    
    static func FromJson(response: [String : Any]?) -> XenditBillingDetails {
        let billingDetails = XenditBillingDetails()
        if response == nil {
            return billingDetails
        }
        billingDetails.givenNames = response!["given_names"] as? String
        billingDetails.middleName = response!["middle_name"] as? String
        billingDetails.surname = response!["surname"] as? String
        billingDetails.email = response!["email"] as? String
        billingDetails.mobileNumber = response!["mobile_number"] as? String
        billingDetails.phoneNumber = response!["phone_number"] as? String
        billingDetails.address = XenditAddress.FromJson(response: (response!["address"] as? [String: Any]))
        return billingDetails
    }
}
