//
//  JsonEncodeTest.swift
//  XenditTests
//
//  Created by xendit on 05/05/21.
//

import XCTest
@testable import XenditSDKSwift

class JsonEncodeTests: XCTestCase {
    func testEncodeXenditCCToken() {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let token: XenditCCToken = XenditCCToken.init(response: [
            "id": "123",
            "status": "VERIFIED",
            "card_info": [
                "bank": "Test bank"
            ]
        ])!
        let jsonString = try? encoder.encode(token);
        XCTAssertTrue(String(data: jsonString!, encoding: .utf8)! == "{\"id\":\"123\",\"status\":\"VERIFIED\",\"card_info\":{\"bank\":\"Test bank\"}}")
        
        let jsonObject = token.toJsonObject()
        print(jsonObject)
        XCTAssertTrue(jsonObject["id"] as! String == "123")
        let cardInfo = jsonObject["card_info"] as! [String: Any]
        XCTAssertTrue(cardInfo["bank"] as! String == "Test bank")
    }
}
