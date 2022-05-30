//
//  DeleteAccountValidationPopUp.swift
//  Depo
//
//  Created by Hady on 10/20/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import Typist

protocol DeleteAccountValidationPopUpDelegate: AnyObject {
    func deleteAccountValidationPopUpSucceeded(_ popup: DeleteAccountValidationPopUp)
}

final class DeleteAccountValidationPopUp: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4

            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = AppColor.cellShadow.color.cgColor
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textAlignment = .center
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)

            newValue.text = localized(.deleteAccountSecondPopupMessage)
        }
    }

    @IBOutlet weak var phoneNumberInput: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.deleteAccountGSMInput)
            newValue.textField.isEnabled = false
            newValue.textField.textColor = ColorConstants.textDisabled
        }
    }

    @IBOutlet weak var passwordInputView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = localized(.deleteAccountPasswordInput)
            newValue.textField.isSecureTextEntry = true
            newValue.textField.textContentType = .password
            newValue.subtitleLabel.text = localized(.deleteAccountPasswordError)
            newValue.textField.delegate = self
            newValue.textField.returnKeyType = .done

            newValue.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }

    @IBOutlet weak var captchaView: CaptchaView! {
        willSet {
            newValue.isHidden = true
            newValue.captchaAnswerTextField.delegate = self
            newValue.captchaAnswerTextField.textContentType = .none

            newValue.captchaAnswerTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.marineTwoAndTealish.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.marineTwoAndTealish.color.cgColor
            newValue.setTitle(localized(.deleteAccountCancelButton), for: .normal)
        }
    }

    @IBOutlet weak var confirmButton: UIButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.backgroundColor = AppColor.marineTwoAndTealish.color
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.setTitle(localized(.deleteAccountContinueButton), for: .normal)
        }
    }

    private let keyboard = Typist()
    private let captchaRequirementService = CaptchaSignUpRequrementService()
    private let authenticationService = AuthenticationService()
    private let analyticsService: AnalyticsService = factory.resolve()
    weak var delegate: DeleteAccountValidationPopUpDelegate?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColor.popUpBackground.color
        setPhoneNumberText()
        setupKeyboard()
        setCaptchaRequired(false)
        setConfirmButtonEnabled(false)

        checkCaptchaRequired()
    }


    // MARK: - Actions
    @IBAction private func cancelButtonTapped() {
        trackCancelButton()
        dismiss(animated: true)
    }

    @IBAction private func confirmButtonTapped() {
        trackConfirmButton()
        validatePassword()
    }

    @objc private func textFieldChanged() {
        let hasPassword = passwordInputView.textField.text?.isEmpty == false

        if captchaView.isHidden {
            setConfirmButtonEnabled(hasPassword)
        } else {
            setConfirmButtonEnabled(
                hasPassword && captchaView.captchaAnswerTextField.text?.isEmpty == false
            )
        }

        // filling password from keychain can overwrite the phone number input with username
        // this is a fix to make sure it's always the phone number showing
        setPhoneNumberText()
    }


    // MARK: - View Config
    private func setPhoneNumberText() {
        phoneNumberInput.textField.text = SingletonStorage.shared.accountInfo?.fullPhoneNumber
    }

    private func setupKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                self?.scrollViewBottomConstraint.constant = options.endFrame.height
                self?.view.layoutIfNeeded()
            }
            .on(event: .didShow) { [weak self] _ in
                self?.scrollView.scrollToBottom(animated: true)
            }
            .on(event: .willHide) { [weak self] options in
                self?.scrollViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
            .start()
    }

    private func hideKeyboard() {
        view.endEditing(true)
    }

    private func setCaptchaRequired(_ isRequired: Bool) {
        captchaView.isHidden = !isRequired
        passwordInputView.textField.returnKeyType = isRequired ? .next : .done
    }

    private func updateCaptchaIfRequired() {
        if !captchaView.isHidden {
            captchaView.updateCaptcha()
        }
    }

    private func setConfirmButtonEnabled(_ isEnabled: Bool) {
        confirmButton.isEnabled = isEnabled
        confirmButton.alpha = isEnabled ? 1 : 0.4
    }


    // MARK: - API Calls
    private func checkCaptchaRequired() {
        captchaRequirementService.getCaptchaRequrement(isSignUp: true) { [weak self] result in
            switch result {
            case let .success(isRequired):
                self?.setCaptchaRequired(isRequired)
            case .failed:
                break
            }
        }
    }

    private func validatePassword() {
        passwordInputView.hideSubtitleAnimated()
        captchaView.hideErrorAnimated()
        hideKeyboard()

        let captchaAnswer: CaptchaParametrAnswer?
        if !captchaView.isHidden {
            captchaAnswer = CaptchaParametrAnswer(uuid: captchaView.currentCaptchaUUID,
                                                  answer: captchaView.captchaAnswerTextField.text ?? "")
        } else {
            captchaAnswer = nil
        }

        showSpinner()
        authenticationService.validateLoginPassword(
            password: passwordInputView.textField.text ?? "",
            captchaAnswer: captchaAnswer
        ) { [weak self] result in
            self?.hideSpinner()
            self?.handlePasswordValidationResult(result)
        }
    }

    private func handlePasswordValidationResult(_ result: AuthenticationService.ValidateLoginPasswordResult) {
        switch result {
        case .valid:
            delegate?.deleteAccountValidationPopUpSucceeded(self)

        case .invalidPassword:
            passwordInputView.showSubtitleAnimated()
            updateCaptchaIfRequired()
            passwordInputView.textField.text = nil
            textFieldChanged()

        case .invalidCaptcha:
            setCaptchaRequired(true)
            captchaView.showErrorAnimated(text: TextConstants.invalidCaptcha)
            updateCaptchaIfRequired()
        }
    }
}

extension DeleteAccountValidationPopUp: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordInputView.textField {
            if !captchaView.isHidden {
                captchaView.captchaAnswerTextField.becomeFirstResponder()
                return true
            }
        }

        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case passwordInputView.textField:
            passwordInputView.hideSubtitleAnimated()
        case captchaView.captchaAnswerTextField:
            captchaView.hideErrorAnimated()
        default:
            break
        }
    }
}

extension DeleteAccountValidationPopUp {
    func trackCancelButton() {
        analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                            eventActions: .deleteMyAccountStep2,
                                            eventLabel: .cancel)
    }

    func trackConfirmButton() {
        analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                            eventActions: .deleteMyAccountStep2,
                                            eventLabel: .continue)
    }
}

extension DeleteAccountValidationPopUp {
    static func instance() -> DeleteAccountValidationPopUp {
        let instance = DeleteAccountValidationPopUp()
        instance.modalTransitionStyle = .crossDissolve
        instance.modalPresentationStyle = .overFullScreen
        return instance
    }
}
