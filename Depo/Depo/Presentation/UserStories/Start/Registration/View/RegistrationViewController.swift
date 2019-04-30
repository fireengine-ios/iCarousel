//
//  RegistrationViewController.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

protocol RegistrationViewDelegate: class {
    func show(errorString: String)
    func showCaptcha()
}

final class RegistrationViewController: ViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var shadowView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var nextButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.registrationNextButtonText, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var alertsStackView: UIStackView! {
        willSet {
            newValue.spacing = 0
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet weak var captchaView: CaptchaView! {
        willSet {
            ///need to hide content
            newValue.layer.masksToBounds = true
            newValue.errorLabel.text = TextConstants.loginScreenInvalidCaptchaError
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        willSet {
            let dismissKeyboardGuesture = UITapGestureRecognizer(target: self,
                                                                 action: #selector(stopEditing))
            newValue.addGestureRecognizer(dismissKeyboardGuesture)
            newValue.delaysContentTouches = false
        }
    }
    
    //MARK: Vars
    private let keyboard = Typist.shared
    var output: RegistrationViewOutput!
    var placeholderColor = UIColor.lightGray

    ///Fields (in right order)
    private let phoneEnterView: ProfilePhoneEnterView = {
        let newValue = ProfilePhoneEnterView()
        newValue.numberTextField.enablesReturnKeyAutomatically = true
        
        let attributedPlaceholder = NSAttributedString(string: TextConstants.profilePhoneNumberPlaceholder,
                                                       attributes: [
                                                        .foregroundColor : UIColor.lightGray
            ])
        newValue.numberTextField.attributedPlaceholder = attributedPlaceholder
        newValue.titleLabel.text = TextConstants.registrationCellTitleGSMNumber
        
        return newValue
    }()
    
    private let emailEnterView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocapitalizationType = .none
        newValue.textField.autocorrectionType = .no
        let attributedPlaceholder = NSAttributedString(string: TextConstants.enterYourEmailAddress,
                                                       attributes: [
                                                        .foregroundColor : UIColor.lightGray
            ])
        newValue.textField.attributedPlaceholder = attributedPlaceholder
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleEmail
        
        return newValue
    }()
    
    private let passwordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        newValue.textField.enablesReturnKeyAutomatically = true
        
        let attributedPlaceholder = NSAttributedString(string: TextConstants.enterYourNewPassword,
                                                       attributes: [
                                                        .foregroundColor : UIColor.lightGray
            ])
        newValue.textField.attributedPlaceholder = attributedPlaceholder
        newValue.titleLabel.text = TextConstants.registrationCellTitlePassword
        
        return newValue
    }()
    
    private let rePasswordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        let attributedPlaceholder = NSAttributedString(string: TextConstants.reenterYourPassword,
                                                       attributes: [
                                                        .foregroundColor : UIColor.lightGray
            ])
        newValue.textField.attributedPlaceholder = attributedPlaceholder
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        
        return newValue
    }()
    
    private let supportView: SignUpSupportView = {
        let newValue = SignUpSupportView()
        newValue.isHidden = true
        
        return newValue
    }()

    private let errorView: SignUpErrorView = {
        let newValue = SignUpErrorView()
        newValue.isHidden = true

        return newValue
    }()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()

        if !captchaView.isHidden {
            captchaView.updateCaptcha()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !output.isSupportFormPresenting {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        output.isSupportFormPresenting = false

    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    //MARK: Utility Methods (private)
    private func setup() {
        setupStackView()
        configureKeyboard()
    }
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setNavigationTitle(title: TextConstants.registerTitle)
    }
    
    private func setupStackView() {
        prepareFields()
        
        supportView.delegate = self
        
        alertsStackView.addArrangedSubview(supportView)
        alertsStackView.addArrangedSubview(errorView)

        stackView.addArrangedSubview(phoneEnterView)
        stackView.addArrangedSubview(emailEnterView)
        stackView.addArrangedSubview(passwordEnterView)
        stackView.addArrangedSubview(rePasswordEnterView)
    }
    
    private func prepareFields() {
        emailEnterView.textField.delegate = self
        passwordEnterView.textField.delegate = self
        rePasswordEnterView.textField.delegate = self
        phoneEnterView.numberTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        phoneEnterView.responderOnNext = emailEnterView.textField
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                self.updateScroll(with: options.endFrame)
            }
            .on(event: .didChangeFrame) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                
                self.updateScroll(with: options.endFrame)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                var inset = self.scrollView.contentInset
                inset.bottom = 0
                self.scrollView.contentInset = inset
                self.scrollView.scrollIndicatorInsets = inset
            }
            .start()
    }
    
    private func updateScroll(with keyboardFrame: CGRect) {
        var bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY
        
        if #available(iOS 11.0, *) {
            bottomInset -= scrollView.safeAreaInsets.bottom
        }
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        
        guard let firstResponser = self.view.firstResponder as? UIView else {
            return
        }
        
        let rectToShow = self.view.convert(firstResponser.frame, to: self.view)
        let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: NumericConstants.firstResponderBottomOffset)
        self.scrollView.scrollRectToVisible(rectToShowWithInset, animated: true)
    }
    
    private func hideErrorBanner() {
        self.errorView.isHidden = true
    }
    
    private func updateCaptcha() {
        captchaView.updateCaptcha()
    }
    
    private func presentCaptcha() {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.captchaView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: IBActions
    @IBAction func nextActionHandler(_ sender: Any) {
        stopEditing()
        hideErrorBanner()
        output.nextButtonPressed()
    }
    
    //MARK: Actions
    @objc private func stopEditing() {
        self.view.endEditing(true)
    }
}

extension RegistrationViewController: RegistrationViewInput {
    func collectInputedUserInfo() {
        output.collectedUserInfo(email: emailEnterView.textField.text ?? "",
                                 code: phoneEnterView.codeTextField.text ?? "",
                                 phone: phoneEnterView.numberTextField.text ?? "",
                                 password: passwordEnterView.textField.text ?? "",
                                 repassword: rePasswordEnterView.textField.text ?? "",
                                 captchaID: captchaView.currentCaptchaUUID,
                                 captchaAnswer: captchaView.captchaAnswerTextField.text ?? "")
    }
    
    func showInfoButton(forType type: UserValidationResults) {
        switch type {
        case .mailNotValid:
            emailEnterView.showSubtitleTextAnimated(text: TextConstants.registrationMailError)
        case .mailIsEmpty:
            emailEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderEmail)
        case .passwordIsEmpty:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderPassword)
        case .passwordNotValid:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordError)
        case .repasswordIsEmpty:
            rePasswordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderReFillPassword)
        case .passwodsNotMatch:
            passwordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordNotMatchError)
        case .phoneIsEmpty:
            phoneEnterView.showTextAnimated(text: TextConstants.registrationCellPlaceholderPhone)
        case .captchaIsEmpty:
            captchaView.showErrorAnimated()
        }
    }
    
    func showErrorTitle(withText: String) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorView.message = withText
            self.errorView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
        
        let errorRect = self.view.convert(errorView.frame, to: self.view)
        scrollView.scrollRectToVisible(errorRect, animated: true)
    }
    
    func setupCaptcha() {
        presentCaptcha()
    }
    
    func showSupportView() {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.supportView.isHidden = false
            
            self.view.layoutIfNeeded()
        }
        
        let supportRect = self.view.convert(supportView.frame, to: self.view)
        scrollView.scrollRectToVisible(supportRect, animated: true)
    }
}

extension RegistrationViewController: RegistrationViewDelegate {
    
    func show(errorString: String) {
        DispatchQueue.toMain {
            self.showErrorTitle(withText: errorString)
        }
    }
    
    func showCaptcha() {
        presentCaptcha()
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case phoneEnterView.numberTextField:
            phoneEnterView.responderOnNext?.becomeFirstResponder()
            
        case emailEnterView.textField:
            passwordEnterView.textField.becomeFirstResponder()
            
        case passwordEnterView.textField:
            rePasswordEnterView.textField.becomeFirstResponder()
            
        case rePasswordEnterView.textField:
            if captchaView.isHidden {
                rePasswordEnterView.textField.resignFirstResponder()
            } else {
                captchaView.captchaAnswerTextField.becomeFirstResponder()
            }
            
        case captchaView.captchaAnswerTextField:
            captchaView.captchaAnswerTextField.resignFirstResponder()
            
        default:
            assertionFailure()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case phoneEnterView.numberTextField:
            phoneEnterView.hideSubtitleAnimated()
        case emailEnterView.textField:
            emailEnterView.hideSubtitleAnimated()
        case passwordEnterView.textField:
            passwordEnterView.hideSubtitleAnimated()
        case rePasswordEnterView.textField:
            rePasswordEnterView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            assertionFailure()
        }
        
        guard let attributedPlaceholder = textField.attributedPlaceholder,
            let range = attributedPlaceholder.string.range(of: attributedPlaceholder.string) else {
            return
        }
        
        let placeholder = NSMutableAttributedString(string: attributedPlaceholder.string)
        let nsRange = NSRange(range, in: attributedPlaceholder.string)
        placeholder.addAttribute(.foregroundColor, value: UIColor.clear, range: nsRange)
        textField.attributedPlaceholder = placeholder
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let attributedPlaceholder = textField.attributedPlaceholder,
            let range = attributedPlaceholder.string.range(of: attributedPlaceholder.string) else {
                return
        }
        
        let placeholder = NSMutableAttributedString(string: attributedPlaceholder.string)
        let nsRange = NSRange(range, in: attributedPlaceholder.string)
        placeholder.addAttribute(.foregroundColor, value: placeholderColor, range: nsRange)
        textField.attributedPlaceholder = placeholder
    }
}

// MARK: - RegistrationInteractorOutput
extension RegistrationViewController: SignUpSupportViewDelegate {
    func openSupport() {
        output.openSupport()
    }
}
