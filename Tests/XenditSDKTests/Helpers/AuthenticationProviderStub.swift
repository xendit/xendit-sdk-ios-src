//
//  AuthenticationProviderStub.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 25/11/2018.
//

import Foundation
@testable import XenditSDKSwift


class AuthenticationProviderStub: AuthenticationProviderProtocol {
    var stubResponse: (XenditAuthentication?, XenditError?)

    func authenticate(fromViewController: UIViewController, URL: String, authentication: XenditAuthentication, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.stubResponse.0, self.stubResponse.1)
        }
    }
}
