//
//  FingerprintTests.swift
//  XenditTests
//
//  Created by Vladimir Lyukov on 25/11/2018.
//

import XCTest
@testable import Xendit

class FingerprintTests: XCTestCase {
    func testReturnsPayload() {
        let payload = Fingerprint().payload
        XCTAssertNotNil(payload["fp_language"])
        XCTAssertNotNil(payload["fp_os"])
        XCTAssertNotNil(payload["fp_resolution"])
        XCTAssertNotNil(payload["fp_tz_name"])
        XCTAssertNotNil(payload["fp_tz_offset"])
        XCTAssertNotNil(payload["fp_device"])
        XCTAssertNotNil(payload["fp_idfv"])
        XCTAssertNil(payload["fp_idfa"])
        XCTAssertNotNil(payload["fp_ip"])
        XCTAssertNil(payload["fp_ssid"])
        XCTAssertNil(payload["fp_lat"])
        XCTAssertNil(payload["fp_lon"])
    }
}
