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

    @IBOutlet private weak var button: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(localized(.resetPasswordCompleteButton), for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setBackgroundColor(AppColor.forgetPassButtonDisable.color, for: .disabled)
            newValue.setBackgroundColor(AppColor.forgetPassButtonNormal.color, for: .normal)
            newValue.isEnabled = false
        }
    }
    
    private lazy var validationSet: PasswordValidationSetView = {
        let view = PasswordValidationSetView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)
        
        validationSet.delegate = self
        stackView.addArrangedSubview(validationSet)
        addTapGestureToHideKeyboard()
        trackScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // hidden by LoginViewController on swipe back and forth
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            trackBackEvent()
        }
    }

    @IBAction private func doneButtonTapped() {
        guard let password = validationSet.newPasswordView.textField.text else { return }

        showSpinnerIncludeNavigationBar()
        resetPasswordService.delegate = self
        resetPasswordService.reset(newPassword: password)
    }
}

// MARK: - PasswordValidationSetDelegate
extension ResetPasswordViewController: PasswordValidationSetDelegate {
    func validateNewPassword(with flag: Bool) {
        button?.isEnabled = flag
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
