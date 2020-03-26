//
//  CreateAuthentification.swift
//  XenditExample
//
//  Created by Maxim Bolotov on 3/30/17.
//  Copyright © 2017 Xendit. All rights reserved.
//

import Foundation
import UIKit
import Xendit

class CreateAuthentification: UIViewController {
    
    @IBOutlet weak var tokenIDTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var cardCVNTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Xendit.publishableKey = "xnd_public_development_LH4fWw2s6eAxVR9mHAsSJZi0hx3jWEUb9dIN8lm4It4MPVNl86LIk1Hh1nDUG"
    }
    
    @IBAction func authentificateAction(_ sender: UIButton) {
        
        view.endEditing(true)
                
        let tokenID = tokenIDTextField.text
        let cardCVN = cardCVNTextField.text
        
        if  tokenID == nil, amountTextField.text == nil, cardCVN == nil {
            return
        }
        
        let int = Int(amountTextField.text!)
        let amount = NSNumber(value: int!)

        Xendit.createAuthentication(fromViewController: self, tokenId: tokenID!, amount: amount, onBehalfOf: "5cd8d52d9b60c752da69b9ec") { (authentication, error) in
            if authentication != nil {
                // Will return authentication with id. ID will be used later
                let message = String(format: "TokenID - %@, Status - %@", (authentication?.id)!, (authentication?.status)!)
                self.showAlert(title: "Token", message: message)
            } else {
                // Handle error. Error is of type XenditError
                self.showAlert(title: error!.errorCode, message: error!.message)
            }
        }
    }
    
}
