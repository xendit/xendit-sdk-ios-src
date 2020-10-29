//
//  XenditCustomer.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

public class XenditCustomer: Jsonable {
    public var referenceId: String?
    public var email: String?
    public var givenName: String?
    public var middleName: String?
    public var surname: String?
    public var description: String?
    public var mobileNumber: String?
    public var phoneNumber: String?
    public var nationality: String?
    public var dateOfBirth: String? // e.g. 1990-04-13
    public var metadata: [String: String]?
    public var addresses: [XenditAddress]?
    
    public init() {}
    
    static func FromJson(response: [String : Any]?) -> XenditCustomer {
        let xenditCustomer = XenditCustomer()
        if response == nil {
            return xenditCustomer
        }
        xenditCustomer.referenceId = response!["reference_id"] as? String
        xenditCustomer.email = response!["email"] as? String
        xenditCustomer.givenName = response!["given_names"] as? String
        xenditCustomer.middleName = response!["middle_name"] as? String
        xenditCustomer.surname = response!["surname"] as? String
        xenditCustomer.description = response!["description"] as? String
        xenditCustomer.mobileNumber = response!["mobile_number"] as? String
        xenditCustomer.phoneNumber = response!["phone_number"] as? String
        xenditCustomer.nationality = response!["nationality"] as? String
        xenditCustomer.dateOfBirth = response!["date_of_birth"] as? String
        
        xenditCustomer.metadata = response!["metadata"] as? [String: String]
        let addresses = response!["addresses"] as? [[String: Any]]
        if addresses != nil && (addresses?.count ?? 0) > 0 {
            xenditCustomer.addresses = []
            addresses?.forEach() {
                (address) in
                xenditCustomer.addresses?.append(XenditAddress.FromJson(response: address))
            }
        }
                
        return xenditCustomer
    }
    
    func toJsonObject() -> [String : Any] {
        var json: [String: Any] = [:]
        if referenceId != nil { json["reference_id"] = referenceId }
        if email != nil { json["email"] = email }
        if givenName != nil { json["given_names"] = givenName }
        if middleName != nil { json["middle_name"] = middleName }
        if surname != nil { json["surname"] = surname }
        if description != nil { json["description"] = description }
        if phoneNumber != nil { json["phone_number"] = mobileNumber }
        if mobileNumber != nil { json["mobile_number"] = mobileNumber }
        if nationality != nil { json["nationality"] = mobileNumber }
        if dateOfBirth != nil { json["date_of_birth"] = mobileNumber }
        if metadata != nil {
            var jsonMetadata = [:] as [String: String]
            for (key, value) in metadata! {
                jsonMetadata[key] = value
            }
            json["metadata"] = jsonMetadata
        }
        if addresses != nil && (addresses?.count ?? 0 > 0) {
            var jsonAddresses = [[String: Any]]()
            for address in addresses! {
                jsonAddresses.append(address.toJsonObject())
            }
            json["addresses"] = jsonAddresses
        }
        
        return json
    }
}
