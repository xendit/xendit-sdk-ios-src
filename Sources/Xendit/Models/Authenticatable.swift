//
//  Authenticatable.swift
//  Xendit
//
//  Created by xendit on 28/10/20.
//

import Foundation

protocol Authenticatable {
    func getPayerAuthenticationUrl() -> String?
}
