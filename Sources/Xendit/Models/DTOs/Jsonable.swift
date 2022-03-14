//
//  JsonSerializable.swift
//  Xendit
//
//  Created by xendit on 29/10/20.
//

import Foundation

protocol Jsonable: JsonSerializable, JsonDeserializable {
}

protocol JsonSerializable {
    func toJsonObject() -> [String: Any]
}

protocol JsonDeserializable {
    associatedtype T
    static func FromJson(response: [String: Any]?) -> T
}
