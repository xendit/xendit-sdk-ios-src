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
        Xendit.publishableKey = "xnd_public_development_9fB0J1Ase70afEL6FPJTBrpIc5NfJCu6evsAxiHSECvUDiz6ZAKWryQObfkS"
        
    }
    
    
    @IBAction func createTokenAction(_ sender: UIButton) {
        
        view.endEditing(true)
        let cvn = cardCvnTextField.text
        let cardData = XenditCardData.init(cardNumber: cardNumberTextField.text!, cardExpMonth: cardExpMonthTextField.text!, cardExpYear: cardExpYearTextField.text!)
        cardData.cardCvn = cvn
        
        let isMultipleUse = isMultipleUseSwitch.isOn
        let currency = "IDR"
        let amount =  NSNumber(value: Double.init(amountTextField.text!)!)
        let tokenizationRequest = XenditTokenizationRequest.init(cardData: cardData, isSingleUse: !isMultipleUse, shouldAuthenticate: true, amount: amount, currency: currency)
        
        let billingDetails: XenditBillingDetails = XenditBillingDetails()
        billingDetails.givenNames = "John"
        billingDetails.surname = "Smith"
        billingDetails.address = XenditAddress()
        billingDetails.address?.postalCode = "123456"

        Xendit.createToken(fromViewController: self, tokenizationRequest: tokenizationRequest, onBehalfOf: nil) { (token, error) in
            if let token = token {
                // Handle successful tokenization. Token is of type XenditCCToken
                let issuingBank = token.cardInfo?.bank ?? "n/a"
                let country = token.cardInfo?.country ?? "n/a"
                let message = String(format: "TokenID - %@, AuthID - %@, Status - %@, MaskedCardNumber - %@, Should_3DS - %@, IssuingBank - %@, Country - %@", token.id, token.authenticationId ?? "n/a", token.status, token.maskedCardNumber ?? "n/a", token.should3DS?.description ?? "n/a", issuingBank, country)
                self.showAlert(title: "Token", message: message)
            } else {
                // Handle error. Error is of type XenditError
                var errorMessage = error!.message
                if error!.errorCode == "INVALID_USER_ID" {
                    errorMessage = error!.message.replacingOccurrences(of: "for-user-id", with: "onBehalfOf")
                }
                self.showAlert(title: error!.errorCode, message: errorMessage ?? "Error creating token.")
            }
        }
    }
}
