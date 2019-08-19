//
//  ChangeEmailViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class ChangeEmailPopUp: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var mainLabel: UILabel! {
        willSet {
            let text = TextConstants.changeEmailPopUpTopTitle
            let attributes: [NSAttributedStringKey : Any] = [
                .font : UIFont.TurkcellSaturaFont(size: 18),
                .foregroundColor : UIColor.black,
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            
            if let range = text.range(of: TextConstants.enterYourEmail) {
                let nsRange = NSRange(range, in: text)
                
                let boldAttribute: [NSAttributedStringKey : Any] = [ .font : UIFont.TurkcellSaturaBolFont(size: 18) ]
                
                attributedString.addAttributes(boldAttribute, range: nsRange)
            }
            
            newValue.attributedText = attributedString
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var darkBackground: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.popUpBackground
        }
    }
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private weak var emailEnterView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = TextConstants.yourEmail
            newValue.titleLabel.textColor = ColorConstants.coolGrey
            newValue.titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            
            newValue.textField.autocorrectionType = .no
            newValue.textField.autocapitalizationType = .none
            
            newValue.textField.delegate = self
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    @IBOutlet private weak var confirmEmailEnterView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = TextConstants.confirmYourEmail
            newValue.titleLabel.textColor = ColorConstants.coolGrey
            newValue.titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            
            newValue.textField.autocorrectionType = .no
            newValue.textField.autocapitalizationType = .none
            
            newValue.textField.delegate = self
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    @IBOutlet private weak var cancelButton: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            newValue.layer.borderWidth = 1
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var changeButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.change, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish.withAlphaComponent(0.5), for: .disabled)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textColor = ColorConstants.textOrange
            newValue.isHidden = true
        }
    }
    
    var completion: VoidHandler?
    
    private let keyboard = Typist()
    private let activityManager = ActivityIndicatorManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        changeButtonStatus()
    }
    
    private func setup() {
        configureKeyboard()
        activityManager.delegate = self
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                var bottomInset = options.endFrame.height
                
                if #available(iOS 11.0, *) {
                    bottomInset -= self.scrollView.safeAreaInsets.bottom
                }
                
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
            }
            .on(event: .didShow) { [weak self] options in
                self?.updateScroll()
            }
            .on(event: .willHide) { [weak self] _ in
                
                self?.scrollView.contentInset = .zero
                self?.scrollView.scrollIndicatorInsets = .zero
            }
            .start()
    }
    
    private func updateScroll() {
        let rectToShow = self.view.convert(self.contentView.frame, to: self.view)
        let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: 16)
        self.scrollView.scrollRectToVisible(rectToShowWithInset,
                                            animated: true)
    }
    
    private func changeButtonStatus() {
        let isButtonEnabled = self.emailEnterView.textField.text.hasCharacters
            && self.confirmEmailEnterView.textField.text.hasCharacters
        
        changeButton.isEnabled = isButtonEnabled
    }
    
    private func compareFields() {
        if let email = emailEnterView.textField.text, email == confirmEmailEnterView.textField.text, email.hasCharacters {
            
            self.updateEmail(email: email)
            dismissKeyboard()
        } else {
            fail(error: TextConstants.fieldsAreNotMatch)
            
            ///after error message appear pop up size is changing
            updateScroll()
        }
    }
    
    private func backToVerifyEmailPopUp() {
        dismissKeyboard()
        
        dismiss(animated: true) { [weak self] in
            self?.completion?()
        }
    }

    private func fail(error: String) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.text = error
            self.errorLabel.isHidden = false
        }
    }
    
    //MARK: Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        changeButtonStatus()
    }

    @IBAction private func changeButtonPressed(_ sender: Any) {
        compareFields()
    }
    
    @IBAction private func cancelButtonPressed(_ sender: Any) {
        backToVerifyEmailPopUp()
    }
}

//MARK: - ActivityIndicator
extension ChangeEmailPopUp: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

//MARK: - UITextFieldDelegate
extension ChangeEmailPopUp: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailEnterView.textField:
            confirmEmailEnterView.textField.becomeFirstResponder()
            
        case confirmEmailEnterView.textField:
            confirmEmailEnterView.resignFirstResponder()
            compareFields()
            
        default:
            assertionFailure()
        }
        
        return true
    }
}

//MARK: - Interactor
extension ChangeEmailPopUp {
    private func updateEmail(email: String) {
        startActivityIndicator()
        
        let parameters = UserEmailParameters(userEmail: email)
        AccountService().updateUserEmail(parameters: parameters,
                                         success: { [weak self] response in
                                            MenloworksEventsService.shared.onEmailChanged()
                                            
                                            SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: {_ in
                                                DispatchQueue.main.async {
                                                    self?.stopActivityIndicator()
                                                    self?.backToVerifyEmailPopUp()
                                                }
                                            }, fail: { [weak self] error in
                                                DispatchQueue.main.async {
                                                    self?.stopActivityIndicator()
                                                    self?.fail(error: error.description)
                                                }
                                            })
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.stopActivityIndicator()
                    self?.fail(error: error.description)
                }
        })
    }
    
}
