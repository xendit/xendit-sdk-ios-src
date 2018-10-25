//
//  XCTest+Extensions.swift
//  XenditExampleUITests
//
//  Created by Vladimir Lyukov on 25/10/2018.
//  Copyright © 2018 Xendit. All rights reserved.
//

import XCTest


extension XCUIElementQuery {
    func withLabelPrefix(_ prefix: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label BEGINSWITH '\(prefix)'")
        return element(matching: predicate)
    }
}


extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        typeText(deleteString)
        typeText(text)
    }

    /**
     Returns "message" label text for UIAlert element.
     */
    var alertMessage: String {
        return staticTexts.element(boundBy: 1).label
    }
}
