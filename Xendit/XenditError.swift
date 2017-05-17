//
//  XenditError.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/16/17.
//
//

import Foundation

@objc(XENError) open class XenditError: NSObject {

    // Error Code
    @objc(errorCode) open var errorCode: String!

    // Message
    open var message : String!

}

extension XenditError {
    convenience init?(errorCode: String, message: String) {
        self.init()
        self.errorCode = errorCode
        self.message = message
    }
}
