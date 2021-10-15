//
//  RegistrationViewController.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

protocol RegistrationViewDelegate: AnyObject {
    func show(errorString: String)
    func showCaptcha()
}

final class RegistrationViewController: ViewController {

    //MARK: IBOutlets
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var nextButton: RoundedInsetsButton! {
        willSet {
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(AppColor.inactiveButtonColor.color ?? ColorConstants.lighterGray, for: .disabled)
            newValue.setTitleColor(ColorConstants.whiteColor, for: .normal)
            newValue.setTitleColor(AppColor.textPlaceholderColor.color ?? ColorConstants.lightGrayColor, for: .disabled)
            newValue.titleLabel?.font = ApplicationPalette.mediumRoundButtonFont
            newValue.setTitle(TextConstants.registrationNextButtonText, for: .normal)
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var alertsStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
        }
    }
    
    @IBOutlet private weak var captchaView: CaptchaView! {
        willSet {
            ///need to hide content
            newValue.layer.masksToBounds = true
            newValue.isHidden = true
            newValue.errorLabel.text = TextConstants.captchaIsEmpty
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            let dismissKeyboardGuesture = UITapGestureRecognizer(target: self,
                                                                 action: #selector(stopEditing))
            newValue.addGestureRecognizer(dismissKeyboardGuesture)
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var bannerView: SupportFormBannerView! {
        willSet {
            newValue.isHidden = true
            newValue.delegate = self
            newValue.screenType = .signup
        }
    }
    
    //MARK: Vars
    
    private let keyboard = Typist.shared
    var output: RegistrationViewOutput!
    private let updateScrollDelay: DispatchTime = .now() + 0.3
    private let termsViewController = RegistrationTermsViewController()
    private var textObserver: NSObjectProtocol?
    
    ///Fields (in right order)
    private let phoneEnterView: ProfilePhoneEnterView = {
        let newValue = ProfilePhoneEnterView()
        newValue.numberTextField.enablesReturnKeyAutomatically = true

        newValue.numberTextField.quickDismissPlaceholder = TextConstants.profilePhoneNumberPlaceholder
        newValue.titleLabel.text = TextConstants.registrationCellTitleGSMNumber
        
        return newValue
    }()
    
    private let emailEnterView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocapitalizationType = .none
        newValue.textField.autocorrectionType = .no
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleEmail
        
        return newValue
    }()
    
    private let passwordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        newValue.textField.enablesReturnKeyAutomatically = true
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourNewPassword
        newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        newValue.titleLabel.text = TextConstants.registrationCellTitlePassword
        
        return newValue
    }()
    
    private let rePasswordEnterView: ProfilePasswordEnterView = {
        let newValue = ProfilePasswordEnterView()
        
        newValue.textField.quickDismissPlaceholder = TextConstants.reenterYourPassword
        newValue.textField.enablesReturnKeyAutomatically = true
        
        newValue.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        
        return newValue
    }()

    private let validationStackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 11
        newValue.axis = .vertical
        newValue.alignment = .fill
        newValue.distribution = .fillEqually

        return newValue
    }()

    private let characterRuleView: PasswordRulesView = {
        let newValue = PasswordRulesView()
        newValue.titleLabel.text = TextConstants.passwordCharacterLimitRule

        return newValue
    }()

    private let capitalizationRuleView: PasswordRulesView = {
        let newValue = PasswordRulesView()
        newValue.titleLabel.text = TextConstants.passwordCapitalizationAndNumberRule

        return newValue
    }()

    private let sequentialRuleView: PasswordRulesView = {
        let newValue = PasswordRulesView()
        newValue.titleLabel.text = TextConstants.passwordSequentialRule

        return newValue
    }()

    @IBOutlet private weak var errorView: ErrorBannerView! {
        willSet {
            newValue.isHidden = true
        }
    }

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
            updateCaptcha()
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
        setupTermsViewController()
        observePhoneInputChanges()
        configureKeyboard()
    }
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setNavigationTitle(title: TextConstants.registerTitle)
        setNavigationRightBarButton(title: TextConstants.loginFAQButton, target: self, action: #selector(handleFaqButtonTap))
    }

    private func setupStackView() {
        prepareFields()

        stackView.addArrangedSubview(phoneEnterView)
        stackView.addArrangedSubview(emailEnterView)
        stackView.addArrangedSubview(passwordEnterView)
        setupValidationStackView()
        stackView.addArrangedSubview(validationStackView)
        stackView.addArrangedSubview(rePasswordEnterView)
    }

    private func setupValidationStackView() {
        validationStackView.addArrangedSubview(characterRuleView)
        validationStackView.addArrangedSubview(capitalizationRuleView)
        validationStackView.addArrangedSubview(sequentialRuleView)

        validationStackView.isHidden = true
    }
    
    private func prepareFields() {
        output.prepareCaptcha(captchaView)
        
        emailEnterView.textField.delegate = self
        passwordEnterView.textField.delegate = self
        textObserver = passwordEnterView.textField.observe(\.text, options: .new, changeHandler: { [output] textField, change in
            output?.validatePassword(textField.text ?? "", repassword: nil)
        })
        rePasswordEnterView.textField.delegate = self
        phoneEnterView.numberTextField.delegate = self
        captchaView.captchaAnswerTextField.delegate = self
        
        phoneEnterView.responderOnNext = emailEnterView.textField
    }

    private func setupTermsViewController() {
        termsViewController.delegate = self
        addChild(termsViewController)
        stackView.addArrangedSubview(termsViewController.view)
        termsViewController.didMove(toParent: self)
    }

    private func observePhoneInputChanges() {
        phoneEnterView.numberTextField.addTarget(self, action: #selector(phoneInputChanged), for: .editingChanged)
        phoneEnterView.onCodeChanged = { [weak self] in
            self?.phoneInputChanged()
        }
    }
    
    private func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
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
        let bottomInset = keyboardFrame.height + UIScreen.main.bounds.height - keyboardFrame.maxY - scrollView.safeAreaInsets.bottom
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        
        scrollToFirstResponder()
    }
    
    private func scrollToFirstResponder() {
        guard let firstResponser = self.view.firstResponder as? UIView else {
            return
        }
        
        let rectToShow: CGRect
        ///FE-1124 requerments (show nextButton if rePasswordField become first responder)
        if firstResponser == rePasswordEnterView.textField || firstResponser == captchaView.captchaAnswerTextField {
            rectToShow = self.view.convert(nextButton.frame, to: self.view)
        } else {
            rectToShow = self.view.convert(firstResponser.frame, to: self.view)
        }
        
        let rectToShowWithInset = rectToShow.offsetBy(dx: 0, dy: NumericConstants.firstResponderBottomOffset)
        self.scrollView.scrollRectToVisible(rectToShowWithInset, animated: true)
    }
    
    private func hideErrorBanner() {
        self.errorView.isHidden = true
    }
    
    private func presentCaptcha() {
        ///fix animation if appears captcha and error both
        UIView.performWithoutAnimation {
            self.captchaView.isHidden = false
        }
    }
    
    //MARK: IBActions
    @IBAction func nextActionHandler(_ sender: Any) {
        stopEditing()
        hideErrorBanner()
        output.nextButtonPressed()
    }
    
    //MARK: Actions
    @objc func textFieldDidChange(_ textField: UITextField) {
        if passwordEnterView.textField == textField {
            output.validatePassword(passwordEnterView.textField.text ?? "", repassword: nil)
        }
    }

    @objc private func stopEditing() {
        self.view.endEditing(true)
    }
    
    @objc private func handleFaqButtonTap() {
        output.openFaqSupport()
    }

    @objc private func phoneInputChanged() {
        output?.phoneNumberChanged(phoneEnterView.codeTextField.text ?? "",
                                   phoneEnterView.numberTextField.text ?? "")
    }
}

extension RegistrationViewController: RegistrationViewInput {
    func validatePasswordRules(forType rules: ValidationRules) {
        switch rules {
        case .capitalizationAndNumberRule:
            capitalizationRuleView.status = .valid
        case .characterLimitRule:
            characterRuleView.status = .valid
        case .sequentialRule:
            sequentialRuleView.status = .valid
        }
    }

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
            capitalizationRuleView.status = .unedited
            characterRuleView.status = .unedited
            sequentialRuleView.status = .unedited
        case .passwordMissingNumbers:
            if capitalizationRuleView.status != .invalid { capitalizationRuleView.status = .unedited}
        case .passwordMissingLowercase:
            if capitalizationRuleView.status != .invalid { capitalizationRuleView.status = .unedited}
        case .passwordMissingUppercase:
            if capitalizationRuleView.status != .invalid { capitalizationRuleView.status = .unedited}
        case .passwordExceedsSameCharactersLimit:
            if sequentialRuleView.status != .invalid { sequentialRuleView.status = .unedited}
        case .passwordExceedsSequentialCharactersLimit:
            if sequentialRuleView.status != .invalid { sequentialRuleView.status = .unedited}
        case .passwordExceedsMaximumLength:
            if characterRuleView.status != .invalid { characterRuleView.status = .unedited}
        case .passwordBelowMinimumLength:
            if characterRuleView.status != .invalid { characterRuleView.status = .unedited}
        case .repasswordIsEmpty:
            rePasswordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderReFillPassword)
        case .passwordsNotMatch:
            rePasswordEnterView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordNotMatchError)
        case .phoneIsEmpty:
            phoneEnterView.showTextAnimated(text: TextConstants.registrationCellPlaceholderPhone)
        case .captchaIsEmpty:
            showCaptchaError(TextConstants.captchaIsEmpty)
        }
    }
    
    func showErrorTitle(withText: String) {
        errorView.message = withText
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorView.isHidden = false
        }
        
        let errorRect = view.convert(errorView.frame, to: view)
        scrollView.scrollRectToVisible(errorRect, animated: true)
    }
    
    func showCaptchaError(_ text: String) {
        captchaView.showErrorAnimated(text: text)
    }
    
    func setupCaptcha() {
        presentCaptcha()
    }
    
    func showSupportView() {
        bannerView.type = .support
    }
    
    func showFAQView() {
        bannerView.type = .faq
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.bannerView.isHidden = false
        }
    }

    func setupEtk(isShowEtk: Bool) {
        termsViewController.setupEtk(isShowEtk: isShowEtk)
    }

    func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
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
    
    func updateCaptcha() {
        captchaView.updateCaptcha()
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    var showPlaceholderColor: UIColor {
        return .yellow
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordEnterView.textField {
            if characterRuleView.status != .valid { characterRuleView.status = .invalid}
            if capitalizationRuleView.status != .valid { capitalizationRuleView.status = .invalid}
            if sequentialRuleView.status != .valid { sequentialRuleView.status = .invalid}
        }

        if rePasswordEnterView.textField == textField {
            output.validatePassword(
                passwordEnterView.textField.text ?? "",
                repassword: rePasswordEnterView.textField.text ?? ""
            )
        }
    }

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
            if characterRuleView.status == .invalid { characterRuleView.status = .unedited}
            if capitalizationRuleView.status == .invalid { capitalizationRuleView.status = .unedited}
            if sequentialRuleView.status == .invalid { sequentialRuleView.status = .unedited}
            validationStackView.isHidden = false
        case rePasswordEnterView.textField:
            rePasswordEnterView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
            
            ///need to scroll to nextButton(in some cases typist not worked)
            DispatchQueue.main.asyncAfter(deadline: updateScrollDelay) {
                self.scrollToFirstResponder()
            }
        default:
            assertionFailure()
        }
    }
}

// MARK: - RegistrationTermsViewControllerDelegate
extension RegistrationViewController: RegistrationTermsViewControllerDelegate {
    func confirmTermsOfUse(_ confirm: Bool) {
        if confirm {
            openTermsOfUseInfo()
            termsViewController.isTermsOfUseChecked = false
        } else {
            output.confirmTermsOfUse(confirm)
        }
    }

    func confirmEtkTerms(_ confirm: Bool) {
        output.confirmEtk(confirm)
    }

    func termsOfUseTapped() {
        openTermsOfUseInfo()
    }

    func etkTermsTapped() {
        openEtkInfo()
    }

    func privacyPolicyTapped() {
        output.openPrivacyPolicyDescriptionController()
    }

    private func openTermsOfUseInfo() {
        guard let eulaText = output.eulaText else { return }

        let infoViewController = RegistrationTermsInfoViewController(text: eulaText) { [weak self] in
            self?.output.confirmTermsOfUse(true)
            self?.termsViewController.isTermsOfUseChecked = true
        }
        infoViewController.present(over: self)
    }

    private func openEtkInfo() {
        let infoViewController = RegistrationTermsInfoViewController(text: TextConstants.etkHTMLText)
        infoViewController.present(over: self)
    }
}

// MARK: - SupportFormBannerViewDelegate
extension RegistrationViewController: SupportFormBannerViewDelegate {
    func supportFormBannerViewDidClick(_ bannerView: SupportFormBannerView) {
        if bannerView.type == .support {
            output?.openSupport()
        } else {
            bannerView.shouldShowPicker = true
            bannerView.becomeFirstResponder()
        }
    }
    
    func supportFormBannerView(_ bannerView: SupportFormBannerView, didSelect type: SupportFormSubjectTypeProtocol) {
        output.openSubjectDetails(type: type)
    }
    
    func supportFormBannerViewDidCancel(_ bannerView: SupportFormBannerView) {
        bannerView.resignFirstResponder()
        scrollView.setContentOffset(.zero, animated: true)
    }
}
