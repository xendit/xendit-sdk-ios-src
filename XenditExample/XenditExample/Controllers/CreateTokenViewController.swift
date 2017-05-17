//
//  CreateTokenViewController.swift
//  XenditExample
//
//  Created by Maxim Bolotov on 3/30/17.
//  Copyright © 2017 Xendit. All rights reserved.
//

import Foundation
import UIKit
import Xendit

class CreateTokenViewController: UIViewController {
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardExpMonthTextField: UITextField!
    @IBOutlet weak var cardExpYearTextField: UITextField!
    @IBOutlet weak var cardCvnTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var isMultipleUseSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Publishable Key
        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
        
    }
    
    
    @IBAction func createTokenAction(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let cardData = CardData()
        cardData.cardNumber = cardNumberTextField.text
        cardData.cardExpMonth = cardExpMonthTextField.text
        cardData.cardExpYear = cardExpYearTextField.text
        cardData.cardCvn = cardCvnTextField.text
        cardData.isMultipleUse = isMultipleUseSwitch.isOn;
        
        if (amountTextField.text?.characters.count)! > 0 {
            let int = Int(amountTextField.text!)
            cardData.amount = NSNumber(value: int!)
        }
        
        Xendit.createToken(fromViewController: self, cardData: cardData) { (token, error) in
            if token != nil {
                // Handle successful tokenization. Token is of type XenditCCToken
                let message = String(format: "TokenID - %@, Status - %@", (token?.id)!, (token?.status)!)
                self.showAlert(title: "Token", message: message)
            } else {
                // Handle error. Error is of type XenditError
                self.showAlert(title: error!.errorCode, message: error!.message)
            }
        }
    }
}
