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
    
    func toJsonObject() -> [String : any Sendable] {
        var json: [String: any Sendable] = [:]
        if givenNames != nil { json["given_names"] = givenNames }
        if surname != nil { json["surname"] = surname }
        if email != nil { json["email"] = email }
        if mobileNumber != nil { json["mobile_number"] = mobileNumber }
        if phoneNumber != nil { json["phone_number"] = phoneNumber }
        if address != nil { json["address"] = address!.toJsonObject() }
        return json
    }
    
    static func FromJson(response: [String : any Sendable]?) -> XenditBillingDetails {
        let billingDetails = XenditBillingDetails()
        if response == nil {
            return billingDetails
        }
        billingDetails.givenNames = response!["given_names"] as? String
        billingDetails.surname = response!["surname"] as? String
        billingDetails.email = response!["email"] as? String
        billingDetails.mobileNumber = response!["mobile_number"] as? String
        billingDetails.phoneNumber = response!["phone_number"] as? String
        billingDetails.address = XenditAddress.FromJson(response: (response!["address"] as? [String: any Sendable]))
        return billingDetails
    }
}
