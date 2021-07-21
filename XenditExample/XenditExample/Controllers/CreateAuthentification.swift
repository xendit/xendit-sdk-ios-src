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
        
        if tokenID == nil, amountTextField.text == nil, cardCVN == nil {
            return
        }
        
        let amount = NSNumber(value: Double.init(amountTextField.text!)!)
        let currency = "IDR"
        
        let authenticationRequest = XenditAuthenticationRequest.init(tokenId: tokenID!, amount: amount, currency: currency);
        authenticationRequest.cardCvn = cardCVN;

        Xendit.createAuthentication(fromViewController: self, authenticationRequest: authenticationRequest, onBehalfOf: nil) { (authentication, error) in
            if authentication != nil {
                // Will return authentication with id. ID will be used later
                let message = String(format: "AuthenticationId - %@, Status - %@", (authentication?.id)!, (authentication?.status)!)
                self.showAlert(title: "Token", message: message)
            } else {
                // Handle error. Error is of type XenditError
                var errorMessage = error!.message
                if error!.errorCode == "INVALID_USER_ID" {
                    errorMessage = error!.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
                }
                self.showAlert(title: error!.errorCode, message: errorMessage ?? "Error creating authentication.")
            }
        }
    }
    
}
