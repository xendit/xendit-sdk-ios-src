//
//  CardAuthenticationProviderStub.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 25/11/2018.
//

import Foundation
import UIKit
@testable import XenditSDKSwift


class CardAuthenticationProviderStub: CardAuthenticationProviderProtocol {
    func authenticate(fromViewController: UIViewController, URL: String, authenticatedToken: XenditAuthenticatedToken, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.stubResponse.0, self.stubResponse.1)
        }
    }
    
    var stubResponse: (XenditCCToken?, XenditError?)
}
