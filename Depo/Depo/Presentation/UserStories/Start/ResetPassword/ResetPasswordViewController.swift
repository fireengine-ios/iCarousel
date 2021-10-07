//
//  ResetPasswordViewController.swift
//  Depo
//
//  Created by Hady on 9/24/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ResetPasswordViewController: BaseViewController, KeyboardHandler {
    private let analyticsService = AnalyticsService()
    private let resetPasswordService: ResetPasswordService
    private let validator: UserValidator

    init(resetPasswordService: ResetPasswordService, validator: UserValidator = UserValidator()) {
        self.resetPasswordService = resetPasswordService
        self.validator = validator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.axis = .vertical
        }
    }

    @IBOutlet private weak var button: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setTitle(localized(.resetPasswordCompleteButton), for: .normal)
            newValue.setTitleColor(ColorConstants.whiteColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)
            newValue.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)
            newValue.isEnabled = false
        }
    }
    
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
        newValue.textField.enablesReturnKeyAutomatically = true
        newValue.textField.quickDismissPlaceholder = TextConstants.reenterYourPassword
        newValue.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        newValue.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        newValue.textField.returnKeyType = .done
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)

        stackView.addArrangedSubview(passwordEnterView)
        validationStackView.addArrangedSubview(characterRuleView)
        validationStackView.addArrangedSubview(capitalizationRuleView)
        validationStackView.addArrangedSubview(sequentialRuleView)
        stackView.addArrangedSubview(validationStackView)
        stackView.addArrangedSubview(rePasswordEnterView)

        passwordEnterView.textField.delegate = self
        rePasswordEnterView.textField.delegate = self

        addTapGestureToHideKeyboard()

        trackScreen()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // back navigation (swiped / back tapped)
        if parent == nil {
            trackBackEvent()
        }
    }

    @IBAction private func doneButtonTapped() {
        guard let password = passwordEnterView.textField.text else { return }

        showSpinnerIncludeNavigationBar()
        resetPasswordService.delegate = self
        resetPasswordService.reset(newPassword: password)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordEnterView.textField {
            validate(checkRePassword: false)
        } else if textField == rePasswordEnterView.textField {
            validate(checkRePassword: true, silent: true)
        }
    }

    private func validate(checkRePassword: Bool, silent: Bool = false) {
        let password = passwordEnterView.textField.text ?? ""
        let repassword = rePasswordEnterView.textField.text ?? ""

        let errors = validator.validatePassword(password, repassword: checkRePassword ? repassword : nil)

        if !checkRePassword {
            validateRules(errors)
        }
        if !silent {
            handleValidationErrors(errors)
        }
        button.isEnabled = checkRePassword && errors.count == 0
    }

    private func validateRules(_ errors: [UserValidationResults]) {
        if !errors.contains(where: [.passwordBelowMinimumLength,
                                    .passwordExceedsMaximumLength,
                                    .passwordIsEmpty].contains) {
            characterRuleView.status = .valid
        }

        if !errors.contains(where: [.passwordMissingUppercase,
                                    .passwordMissingLowercase,
                                    .passwordMissingNumbers,
                                    .passwordIsEmpty].contains) {
            capitalizationRuleView.status = .valid
        }

        if !errors.contains(where: [.passwordExceedsSequentialCharactersLimit,
                                    .passwordExceedsSameCharactersLimit,
                                    .passwordIsEmpty].contains) {
            sequentialRuleView.status = .valid
        }
    }

    private func handleValidationErrors(_ errors: [UserValidationResults]) {
        errors.forEach { error in
            switch error {
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

            default:
                break
            }
        }
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordEnterView.textField {
            rePasswordEnterView.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordEnterView.textField {
            passwordEnterView.hideSubtitleAnimated()
        } else if textField == rePasswordEnterView.textField {
            rePasswordEnterView.hideSubtitleAnimated()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordEnterView.textField {
            if characterRuleView.status != .valid { characterRuleView.status = .invalid }
            if capitalizationRuleView.status != .valid { capitalizationRuleView.status = .invalid }
            if sequentialRuleView.status != .valid { sequentialRuleView.status = .invalid }
        } else if textField == rePasswordEnterView.textField {
            validate(checkRePassword: true)
        }
    }
}

extension ResetPasswordViewController: ResetPasswordServiceDelegate {
    func resetPasswordServiceChangedPasswordSuccessfully(_ service: ResetPasswordService) {
        hideSpinnerIncludeNavigationBar()
        UIApplication.showSuccessAlert(message: localized(.resetPasswordSuccessMessage)) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        trackResetEvent(error: nil)
    }

    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {
        hideSpinnerIncludeNavigationBar()
        UIApplication.showErrorAlert(message: error.localizedDescription)

        trackResetEvent(error: error)
    }
}

private extension ResetPasswordViewController {
    func trackScreen() {
        analyticsService.logScreen(screen: .resetPassword)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.FPResetPasswordScreen())
    }

    func trackResetEvent(error: Error?) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: .resetPassword,
            eventLabel: .result(error)
        )

        let status: NetmeraEventValues.GeneralStatus = error == nil ? .success : .failure
        AnalyticsService.sendNetmeraEvent(
            event: NetmeraEvents.Actions.FPResetPassword(status: status)
        )
    }

    func trackBackEvent() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.FPResetPasswordBack())
    }
}
