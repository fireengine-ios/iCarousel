//
//  PasswordValidationSetView.swift
//  Depo
//
//  Created by yilmaz edis on 19.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol PasswordValidationSetDelegate: AnyObject {
    func validateNewPassword(with flag: Bool)
}

final class PasswordValidationSetView: UIView {
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 16
        view.axis = .vertical
        return view
    }()
    
    lazy var newPasswordView: ProfilePasswordEnterView = {
        let view = ProfilePasswordEnterView()
        view.textField.enablesReturnKeyAutomatically = true
        view.textField.quickDismissPlaceholder = TextConstants.enterYourNewPassword
        view.textField.addTarget(self, action: #selector(validationTextFieldDidChange), for: .editingChanged)
        view.titleLabel.text = TextConstants.registrationCellTitlePassword
        view.layer.borderColor = AppColor.forgetBorder.cgColor
        view.textField.returnKeyType = .next
        return view
    }()
    
    lazy var rePasswordView: ProfilePasswordEnterView = {
        let view = ProfilePasswordEnterView()
        view.textField.enablesReturnKeyAutomatically = true
        view.textField.quickDismissPlaceholder = TextConstants.reenterYourPassword
        view.textField.addTarget(self, action: #selector(validationTextFieldDidChange), for: .editingChanged)
        view.titleLabel.text = TextConstants.registrationCellTitleReEnterPassword
        view.textField.returnKeyType = .done
        view.layer.borderColor = AppColor.forgetBorder.cgColor
        view.textField.returnKeyType = .next
        return view
    }()
    
    private lazy var validationStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 16
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually

        return view
    }()

    private lazy var characterRuleView: PasswordRulesView = {
        let view = PasswordRulesView()
        view.titleLabel.text = TextConstants.passwordCharacterLimitRule
        view.titleLabel.font = .appFont(.medium, size: 12)
        view.titleLabel.textColor = AppColor.forgetPassText.color
        return view
    }()

    private lazy var capitalizationRuleView: PasswordRulesView = {
        let view = PasswordRulesView()
        view.titleLabel.text = TextConstants.passwordCapitalizationAndNumberRule
        view.titleLabel.font = .appFont(.medium, size: 12)
        view.titleLabel.textColor = AppColor.forgetPassText.color
        return view
    }()

    private lazy var sequentialRuleView: PasswordRulesView = {
        let view = PasswordRulesView()
        view.titleLabel.text = TextConstants.passwordSequentialRule
        view.titleLabel.font = .appFont(.medium, size: 12)
        view.titleLabel.textColor = AppColor.forgetPassText.color
        return view
    }()
    
    var validator: UserValidator = UserValidator()
    weak var delegate: PasswordValidationSetDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(newPasswordView)
        validationStackView.addArrangedSubview(characterRuleView)
        validationStackView.addArrangedSubview(capitalizationRuleView)
        validationStackView.addArrangedSubview(sequentialRuleView)
        stackView.addArrangedSubview(validationStackView)
        stackView.addArrangedSubview(rePasswordView)

        newPasswordView.textField.delegate = self
        rePasswordView.textField.delegate = self
    }
    
    @objc private func validationTextFieldDidChange(_ textField: UITextField) {
        if textField == newPasswordView.textField {
            validate(checkRePassword: false)
        } else if textField == rePasswordView.textField {
            validate(checkRePassword: true, silent: true)
        }
    }
    
    
    func validate(checkRePassword: Bool, silent: Bool = false) {
        let password = newPasswordView.textField.text ?? ""
        let repassword = rePasswordView.textField.text ?? ""

        let errors = validator.validatePassword(password, repassword: checkRePassword ? repassword : nil)

        if !checkRePassword {
            validateRules(errors)
        }
        if !silent {
            handleValidationErrors(errors)
        }
        
        delegate?.validateNewPassword(with: checkRePassword && errors.count == 0)
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
                capitalizationRuleView.status = .invalid
            case .passwordMissingLowercase:
                capitalizationRuleView.status = .invalid
            case .passwordMissingUppercase:
                capitalizationRuleView.status = .invalid
            case .passwordExceedsSameCharactersLimit:
                sequentialRuleView.status = .invalid
            case .passwordExceedsSequentialCharactersLimit:
                sequentialRuleView.status = .invalid
            case .passwordExceedsMaximumLength:
                characterRuleView.status = .invalid
            case .passwordBelowMinimumLength:
                characterRuleView.status = .invalid
            case .repasswordIsEmpty:
                rePasswordView.showSubtitleTextAnimated(text: TextConstants.registrationCellPlaceholderReFillPassword)
            case .passwordsNotMatch:
                rePasswordView.showSubtitleTextAnimated(text: TextConstants.registrationPasswordNotMatchError)

            default:
                break
            }
        }
    }
}

extension PasswordValidationSetView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordView.textField {
            rePasswordView.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == newPasswordView.textField {
            newPasswordView.hideSubtitleAnimated()
        } else if textField == rePasswordView.textField {
            rePasswordView.hideSubtitleAnimated()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newPasswordView.textField {
            if characterRuleView.status != .valid { characterRuleView.status = .invalid }
            if capitalizationRuleView.status != .valid { capitalizationRuleView.status = .invalid }
            if sequentialRuleView.status != .valid { sequentialRuleView.status = .invalid }
        } else if textField == rePasswordView.textField {
            validate(checkRePassword: true)
        }
    }
}
