//
//  PhoneVereficationPhoneVereficationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationViewController: UIViewController, PhoneVereficationViewInput {

    var output: PhoneVereficationViewOutput!

    @IBOutlet weak var codeVereficationField: UITextField!
    
    @IBOutlet weak var timerLabel: SmartTimerLabel!
    
    @IBOutlet weak var resendButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        output.viewIsReady()
    }
    
    @IBAction func ResendCode(_ sender: Any) {
        self.output.resendButtonPressed()
    }
    
    @IBAction func NextAction(_ sender: Any) {
        guard let code = codeVereficationField.text else {
            return
        }
        self.output.nextButtonPressed(withVereficationCode: code)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: PhoneVereficationViewInput
    
    func setupInitialState() {
        self.navigationItem.title = TextConstants.registerTitle
        self.codeVereficationField.delegate = self
        self.resendButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        self.codeVereficationField.becomeFirstResponder()
        self.nextButton.setTitleColor(ColorConstants.blueColor, for: .normal)
//        nextButton.setTitle(<#T##title: String?##String?#>, for: <#T##UIControlState#>)//localise here
    }
    
    func setupTimer() {
        self.timerLabel.setupTimer(withTimeInterval: 1.0,
                                   timerLimit: NumericConstants.vereficationTimerLimit)
        self.timerLabel.delegate = self
    }
    
    func showResendButton() {
        self.resendButton.isHidden = false
        self.resendButton.isEnabled = true
    }
    
    func hideResendButton() {
        self.resendButton.isHidden = true
        self.resendButton.isEnabled = false
    }
    
    func disableNextButton() {
        if self.nextButton.isEnabled {
            self.nextButton.isEnabled = false
            self.nextButton.alpha = 0.5
        }
    }
    
    func enableNextButton() {
        if !self.nextButton.isEnabled {
            self.nextButton.isEnabled = true
            self.nextButton.alpha = 1
        }
    }
}

extension PhoneVereficationViewController: UITextFieldDelegate, SmartTimerLabelDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notAvailableCharacterSet = CharacterSet(charactersIn: "1234567890")
        
        guard let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string),
            newString.characters.count <= NumericConstants.vereficationCharacterLimit,
            string.rangeOfCharacter(from: notAvailableCharacterSet) != nil || string == "" else {
            return false
        }
        
        if newString.characters.count == NumericConstants.vereficationCharacterLimit, !self.timerLabel.isDead {
            
            self.output.vereficationCodeEntered()
        } else {
            self.output.vereficationCodeNotReady()
        }
        
        let atributedString = NSAttributedString(string: textField.text!, attributes: [NSKernAttributeName: 10])
        //        atributedString.addAttributes([NSKernAttributeName: 3], range: NSMakeRange(0, textField.text.lenght))
        self.codeVereficationField.attributedText = atributedString
        
        return true
    }

    func timerDidFinishRunning() {
        self.output.timerFinishedRunning()
    }
}
