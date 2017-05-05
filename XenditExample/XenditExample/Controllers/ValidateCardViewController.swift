//
//  ValidateCardViewController.swift
//  XenditExample
//
//  Created by Maxim Bolotov on 3/30/17.
//  Copyright © 2017 Xendit. All rights reserved.
//

import Foundation
import UIKit
import Xendit

class ValidateCardViewController: UIViewController {
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardExpMonthTextField: UITextField!
    @IBOutlet weak var cardExpYearTextField: UITextField!
    @IBOutlet weak var cardCVNTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func validateAction(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let cardNumber = cardNumberTextField.text
        let cardExpMonth = cardExpMonthTextField.text
        let cardExpYear = cardExpYearTextField.text
        let cardCvn = cardCVNTextField.text
        
        guard cardNumber != nil && Xendit.isCardNumberValid(cardNumber: cardNumber!) else {
            showAlert(title: "Validate Error", message: "Card number is invalid")
            return
        }
        
        guard cardExpMonth != nil && cardExpYear != nil && Xendit.isExpiryValid(cardExpirationMonth: cardExpMonth!, cardExpirationYear: cardExpYear!) else {
            showAlert(title: "Validate Error", message: "Card expiration date is invalid")
            return
        }
        
        guard cardCvn != nil && Xendit.isCvnValid(creditCardCVN: cardCvn!) else {
            showAlert(title: "Validate Error", message: "Card CVN is invalid")
            return
        }
        
        showAlert(title: "Success", message: "Card is valid!")
        
    }
    
}
