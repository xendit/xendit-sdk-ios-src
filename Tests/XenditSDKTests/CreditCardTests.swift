//
//  CreditCardTests.swift
//  XenditTests
//
//  Created by xendit on 22/10/20.
//

import XCTest
@testable import Xendit

class CreditCardTests: XCTestCase {
    func testIsValidCardNumber() {
        //VISA
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "4929939187355598")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "4485383550284604")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "4532307841419094")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "4716014929481859")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "4539677496449015")) //true
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "4129939187355598")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "4485383550184604")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "4532307741419094")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "4716014929401859")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "4539672496449015")) //false
        //Master
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "5454422955385717")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "5582087594680466")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "5485727655082288")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "5523335560550243")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "5128888281063960")) //true
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "5454452295585717")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "5582087594683466")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "5487727655082288")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "5523335500550243")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "5128888221063960")) //false
        //Discover
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "6011574229193527")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "6011908281701522")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "6011638416335074")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "6011454315529985")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "6011123583544386")) //true
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "6011574229193127")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "6031908281701522")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "6011638416335054")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "6011454316529985")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "6011123581544386")) //false
        //American Express
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "348570250878868")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "341869994762900")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "371040610543651")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "341507151650399")) //true
        XCTAssertTrue(CreditCard.isValidCardNumber(cardNumber: "371673921387168")) //true
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "348570250872868")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "341669994762900")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "371040610573651")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "341557151650399")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "371673901387168")) //false
        
        //Invalid values
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "34857868")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "12sdf")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "3710406dfdkjs10573651")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "341551#7151650399")) //false
        XCTAssertFalse(CreditCard.isValidCardNumber(cardNumber: "3716739zz01387168")) //false
    }
}
