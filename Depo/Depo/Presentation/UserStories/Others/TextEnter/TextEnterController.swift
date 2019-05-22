//
//  TextEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

typealias TextEnterHandler = (_ text: String, _ vc: TextEnterController) -> Void

final class TextEnterController: ViewController, NibInit, ErrorPresenter {
    
    var output: RegistrationViewOutput!
    
    // MARK: - Outlets
    
    @IBOutlet private weak var shadowView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = TextConstants.pleaseEnterYourMissingAccountInformation
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    
    @IBOutlet private weak var changeButton: RoundedInsetsButton! {
        didSet {
            changeButton.isExclusiveTouch = true
            changeButton.setTitle(doneButtonTitle, for: .normal)
            changeButton.setTitleColor(UIColor.white, for: .normal)
            changeButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            changeButton.backgroundColor = UIColor.lrTealish
            changeButton.isOpaque = true
        }
    }
    
    @IBOutlet private weak var phoneEnterView: ProfilePhoneEnterView! {
        didSet {
            phoneEnterView.numberTextField.enablesReturnKeyAutomatically = true
        
            phoneEnterView.numberTextField.quickDismissPlaceholder = TextConstants.profilePhoneNumberPlaceholder
            phoneEnterView.titleLabel.text = TextConstants.registrationCellTitleGSMNumber
            
            phoneEnterView.numberTextField.addToolBarWithButton(title: TextConstants.userProfileDoneButton,
                                          target: self,
                                          selector: #selector(hideKeyboard))
        }
    }
    
    private var alertTitle = ""
    private var doneButtonTitle = ""
    
    private lazy var doneAction: TextEnterHandler = { [weak self] _, _ in
        self?.close(completion: nil)
    }
    
    private var phone: String? {
        guard
            let code = phoneEnterView.codeTextField.text,
            let number = phoneEnterView.numberTextField.text
        else {
            return nil
        }
        
        return code + number
    }
    
    // MAKR: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alertTitle
        
        shadowView.isHidden = true
        shadowView.isUserInteractionEnabled = false
        
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func setupDelegates() {
       phoneEnterView.numberTextField.delegate = self
    }

    func startLoading() {
        showSpinner()
    }

    func stopLoading() {
        hideSpinner()
    }
       
    // MARK: - Actions
    
    @IBAction func change(_ sender: UIButton) {
        if verifyPhone() {
            doneAction(phone ?? "", self)
        }
    }
    
    @objc func close(completion: VoidHandler? = nil) {
        view.endEditing(true)
        completion?()
    }
    
    private func verifyPhone() -> Bool {
        guard let phone = phone?.replacingOccurrences(of: "+", with: "") else {
            return false
        }

        guard phone.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return false
        }
        
        guard phone.count > 3 else {
            UIApplication.showErrorAlert(message: TextConstants.invalidPhoneNumberText)
            return false
        }
        
        return true
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Static
extension TextEnterController {
    
    static func with(title: String, buttonTitle: String, buttonAction: TextEnterHandler? = nil) -> TextEnterController {
        
        let vc = TextEnterController.initFromNib()
        vc.alertTitle = title
        vc.doneButtonTitle = buttonTitle
        
        if let action = buttonAction {
            vc.doneAction = action
        }
        
        return vc
    }
}

// MARK: - UITextFieldDelegate
extension TextEnterController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneEnterView.hideSubtitleAnimated()
    }
    
}
