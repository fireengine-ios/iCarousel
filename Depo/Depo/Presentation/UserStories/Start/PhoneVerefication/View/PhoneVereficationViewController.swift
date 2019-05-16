//
//  PhoneVereficationPhoneVereficationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationViewController: ViewController, PhoneVereficationViewInput {
    
    var output: PhoneVereficationViewOutput!

    @IBOutlet weak var phoneCodeLabel: UILabel!
    
    @IBOutlet weak var codeVereficationField: UITextField!
    
    @IBOutlet weak var timerLabel: SmartTimerLabel!
    
    @IBOutlet weak var resendButton: WhiteButtonWithRoundedCorner!
    
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBOutlet weak var infoTitle: UILabel!
    
    @IBOutlet weak var bacgroundImageView: UIImageView!
    
    var inputTextLimit: Int = NumericConstants.vereficationCharacterLimit
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        output.viewIsReady()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidenNavigationBarStyle()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    @IBAction func ResendCode(_ sender: Any) {
        output.resendButtonPressed()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    fileprivate func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: PhoneVereficationViewInput
    
    func setupInitialState() {
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.registerTitle)
        }
        navigationItem.backBarButtonItem?.title = TextConstants.backTitle
        codeVereficationField.delegate = self
        resendButton.setTitle(TextConstants.registrationResendButtonText, for: .normal)
        
        mainTitle.font = UIFont.TurkcellSaturaBolFont(size: 18)
        mainTitle.textColor = UIColor.white
        mainTitle.text = TextConstants.phoneVereficationMainTitleText
        infoTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        changeInfoTextState(state: true)
        infoTitle.text = TextConstants.phoneVereficationInfoTitleText
        timerLabel.isHidden = true
        
    }
    
    func changeInfoTextState(state: Bool) {
        infoTitle.textColor = state ? UIColor.white : ColorConstants.yellowColor
    }
    
    func heighlightInfoTitle() {
        codeVereficationField.text = ""
        changeInfoTextState(state: false)
    }
    
    func setupButtonsInitialState() {
        resendButton.isHidden = true
        resendButton.isEnabled = false
    }
    
    func setupTimer(withRemainingTime remainingTime: Int) {
        timerLabel.isHidden = false
        timerLabel.setupTimer(withTimeInterval: 1.0,
                                   timerLimit: remainingTime)
        timerLabel.delegate = self
    }
    
    func dropTimer() {
        timerLabel.dropTimer()
    }
    
    func resendButtonShow(show: Bool) {
        resendButton.isHidden = !show
        resendButton.isEnabled = show
        codeVereficationField.text = show ? "" : codeVereficationField.text
        codeVereficationField.isEnabled = !show
    }
    
    func setupTextLengh(lenght: Int) {
         inputTextLimit = lenght
    }
    
    func setupPhoneLable(with number: String) {
        phoneCodeLabel.text = number
    }
    
    func getNavigationController() -> UINavigationController? {
        return self.navigationController
    }
}

extension PhoneVereficationViewController: UITextFieldDelegate, SmartTimerLabelDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeInfoTextState(state: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted
        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        if ( result != nil) {
            return false
        }
        
        let resultStr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if ((resultStr as String?)?.count)! == inputTextLimit,
                !timerLabel.isDead {

            output.vereficationCodeEntered(code: resultStr ?? "")
            
            DispatchQueue.main.async { [weak self] in
                self?.codeVereficationField.resignFirstResponder()
            }
        } else if ((resultStr as String?)?.count)! > inputTextLimit {
            return false
        } else {
            output.vereficationCodeNotReady()
        }
        
        let atributedString = NSAttributedString(string: textField.text!, attributes: [NSAttributedStringKey.kern: 20])
        codeVereficationField.attributedText = atributedString

        
        return true
    }

    func timerDidFinishRunning() {
        if (codeVereficationField.text?.lengthOfBytes(using: .utf8) == 0) {
            self.hideKeyboard()
        }
        output.timerFinishedRunning()
    }
}
