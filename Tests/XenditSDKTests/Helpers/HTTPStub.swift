//
//  Stub.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 23/11/2018.
//

import Foundation
import XCTest
import OHHTTPStubs


class HTTPStub {
    enum Endpoint {
        case tokenCredentials
        case createCreditCard
        case authentication(token: String)
        case tokenizeCard

        var path: String {
            switch self {
            case .tokenCredentials: return "/credit_card_tokenization_configuration"
            case .createCreditCard: return "/credit_card_tokens"
            case .authentication(let token): return "/credit_card_tokens/\(token)/authentications"
            case .tokenizeCard: return "/cybersource/flex/v1/tokens"
            }
        }
    }
    enum ResponseFixture: String {
        // Common failures
        case badRequest = "bad_request"
        case htmlResponse = "html"
        case corruptedJson = "corrupted_json"
        case networkError // This error doesn't have `.response` file associated and is handled individually

        // Endpoint success responses
        case tokenCredentialsSuccess = "token_credentials"
        case tokenizeCardSuccess = "tokenize_card"
        case createCreditCardSuccess = "credit_card_tokens"
        case createCreditCard3dsSuccess = "credit_card_tokens_3ds"
        case authenticationSuccess = "authentication"
        case authenticationTokenExpired = "authentication_token_expired"
    }

    func failOnUnexpectedRequest(file: StaticString = #file, line: UInt = #line) {
        stub(condition: { _ in return true }) { request in
            let bodyData = request.ohhttpStubs_httpBody
            let bodyString = bodyData == nil ? "<empty body>" : String(data: bodyData!, encoding: .utf8)!
            let message = "Unexpected request: \(request.httpMethod ?? "n/a") \(request.url?.absoluteString ?? "n/a")\n\(bodyString)"
            XCTFail(message, file: file, line: line)
            return HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
        }
    }

    func respond(_ endpoint: Endpoint, fixture: ResponseFixture) {
        stub(condition: isPath(endpoint.path)) { _ in
            if fixture == .networkError {
                return HTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil))
            }
            return HTTPStubsResponse()
        }
    }

    func tearDown() {
        HTTPStubs.removeAllStubs()
    }

}
