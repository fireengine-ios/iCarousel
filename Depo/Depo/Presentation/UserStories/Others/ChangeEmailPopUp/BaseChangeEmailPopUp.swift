//
//  ChangeEmailViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

class BaseChangeEmailPopUp: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: String(describing: BaseChangeEmailPopUp.self), bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var mainLabel: UILabel! {
        willSet {
            let text = TextConstants.changeEmailPopUpTopTitle
            let attributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.TurkcellSaturaFont(size: 18),
                .foregroundColor : AppColor.blackColor.color,
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            
            if let range = text.range(of: TextConstants.enterYourEmail) {
                let nsRange = NSRange(range, in: text)
                
                let boldAttribute: [NSAttributedString.Key : Any] = [ .font : UIFont.TurkcellSaturaBolFont(size: 18) ]
                
                attributedString.addAttributes(boldAttribute, range: nsRange)
            }
            
            newValue.attributedText = attributedString
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var darkBackground: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.popUpBackground.color
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
            newValue.titleLabel.backgroundColor = AppColor.secondaryBackground.color
            newValue.textField.backgroundColor = AppColor.secondaryBackground.color
            newValue.stackView.backgroundColor = AppColor.secondaryBackground.color

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
            newValue.titleLabel.backgroundColor = AppColor.secondaryBackground.color
            newValue.textField.backgroundColor = AppColor.secondaryBackground.color
            newValue.stackView.backgroundColor = AppColor.secondaryBackground.color
            
            newValue.textField.autocorrectionType = .no
            newValue.textField.autocapitalizationType = .none
            
            newValue.textField.delegate = self
            newValue.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    @IBOutlet private weak var cancelButton: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setBackgroundColor(AppColor.secondaryBackground.color, for: .normal)
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
            newValue.numberOfLines = 0
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
                
                let bottomInset = options.endFrame.height - self.scrollView.safeAreaInsets.bottom
                
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
    
    func backToVerificationPopup() {
        dismissKeyboard()
        
        dismiss(animated: true) { [weak self] in
            self?.completion?()
        }
    }

    func fail(error: String) {
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        backToVerificationPopup()
    }

    func updateEmail(email: String) {
        // Overridden in subclasses
    }

}

//MARK: - ActivityIndicator
extension BaseChangeEmailPopUp: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

//MARK: - UITextFieldDelegate
extension BaseChangeEmailPopUp: UITextFieldDelegate {
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
