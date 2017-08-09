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
        
        Xendit.publishableKey = "xnd_public_development_O4iFfuQhgLOsl8M9eeEYGzeWYNH3otV5w3Dh/BFj/mHW+72nCQR/"
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

        Xendit.createAuthentication(fromViewController: self, tokenId: tokenID!, amount: amount) { (authentication, error) in
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
