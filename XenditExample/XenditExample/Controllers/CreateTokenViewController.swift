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
        Xendit.publishableKey = "xnd_public_development_LH4fWw2s6eAxVR9mHAsSJZi0hx3jWEUb9dIN8lm4It4MPVNl86LIk1Hh1nDUG"
        
    }
    
    
    @IBAction func createTokenAction(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let cardData = CardData()
        cardData.cardNumber = cardNumberTextField.text
        cardData.cardExpMonth = cardExpMonthTextField.text
        cardData.cardExpYear = cardExpYearTextField.text
        cardData.cardCvn = cardCvnTextField.text
        cardData.isMultipleUse = isMultipleUseSwitch.isOn
        
        let billingDetails: XenditBillingDetails = XenditBillingDetails()
        billingDetails.givenNames = "John"
        billingDetails.surname = "Smith"
        billingDetails.address = XenditAddress()
        billingDetails.address?.postalCode = "123456"
        
        if !cardData.isMultipleUse && (amountTextField.text?.count)! > 0 {
            let int = Int(amountTextField.text!)
            cardData.amount = NSNumber(value: int!)
        }
        
        let tokenizationRequest = XenditTokenizationRequest(cardData: cardData, shouldAuthenticate: true)
        tokenizationRequest.billingDetails = billingDetails

        Xendit.createToken(fromViewController: self, tokenizationRequest: tokenizationRequest, onBehalfOf: "") { (token, error) in
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
