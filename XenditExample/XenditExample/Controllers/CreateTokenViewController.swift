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
    @IBOutlet weak var midTextField: UITextField!
    @IBOutlet weak var isMultipleUseSwitch: UISwitch!
    @IBOutlet weak var cardHolderFirstNameTextField: UITextField!
    @IBOutlet weak var cardHolderLastNameTextField: UITextField!
    @IBOutlet weak var cardHolderEmailTextField: UITextField!
    @IBOutlet weak var cardHolderPhoneNumberTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var isSkipAuthenticationSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func createTokenAction(_ sender: UIButton) {
        
        view.endEditing(true)
        let cvn = cardCvnTextField.text
        let cardData = XenditCardData.init(
            cardNumber: cardNumberTextField.text!,
            cardExpMonth: cardExpMonthTextField.text!,
            cardExpYear: cardExpYearTextField.text!,
            cardHolderFirstName: cardHolderFirstNameTextField.text,
            cardHolderLastName: cardHolderLastNameTextField.text,
            cardHolderEmail: cardHolderEmailTextField.text,
            cardHolderPhoneNumber: cardHolderPhoneNumberTextField.text
        )
        cardData.cardCvn = cvn
        
        let isMultipleUse = isMultipleUseSwitch.isOn
        let isSkipAuthentication = isSkipAuthenticationSwitch.isOn
        let currency = currencyTextField.text
        let amountText = amountTextField.text!
        var amount: NSNumber?
        if (amountText != "") {
            amount = NSNumber(value: Double.init(amountText)!)
        }
        let tokenizationRequest = XenditTokenizationRequest.init(cardData: cardData, isSingleUse: !isMultipleUse, shouldAuthenticate: !isSkipAuthentication, amount: amount, currency: currency)
        // Set MID if it is set
        if let text = midTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tokenizationRequest.midLabel = text
        }
        
        let billingDetails: XenditBillingDetails = XenditBillingDetails()
        billingDetails.givenNames = "John"
        billingDetails.surname = "Smith"
        billingDetails.address = XenditAddress()
        billingDetails.address?.postalCode = "123456"
        
        Xendit.publishableKey = apiKeyTextField.text

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
