//
//  CardAuthenticationProviderStub.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 25/11/2018.
//

import Foundation
@testable import Xendit


class CardAuthenticationProviderStub: CardAuthenticationProviderProtocol {
    var stubResponse: (XenditCCToken?, XenditError?)

    func authenticate(fromViewController: UIViewController, URL: String, token: XenditCCToken, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.stubResponse.0, self.stubResponse.1)
        }
    }
}
