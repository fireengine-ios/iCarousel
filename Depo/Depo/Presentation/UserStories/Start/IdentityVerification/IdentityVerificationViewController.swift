//
//  IdentityVerificationViewController.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class IdentityVerificationViewController: BaseViewController {
    private let analyticsService = AnalyticsService()
    private let resetPasswordService: ResetPasswordService
    let availableMethods: [IdentityVerificationMethod]

    init(resetPasswordService: ResetPasswordService, availableMethods: [IdentityVerificationMethod]) {
        self.resetPasswordService = resetPasswordService
        self.availableMethods = availableMethods
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet private var tableHeaderView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var tableView: ResizableTableView! {
        willSet {
            newValue.alwaysBounceVertical = false
        }
    }

    @IBOutlet private weak var continueButton: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setTitle(localized(.resetPasswordContinueButton), for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setBackgroundColor(AppColor.forgetPassButtonDisable.color, for: .disabled)
            newValue.setBackgroundColor(AppColor.forgetPassButtonNormal.color, for: .normal)
        }
    }

    private var dataSource: IdentityVerificationDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)

        dataSource = IdentityVerificationDataSource(tableView: tableView)
        dataSource.availableMethods = availableMethods

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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupHeader()
    }

    @IBAction private func continueButtonTapped() {
        guard let selectedMethod = dataSource.selectedMethod else { return }

        showSpinner()
        resetPasswordService.delegate = self
        resetPasswordService.proceedVerification(with: selectedMethod)

        trackContinueEvent(method: selectedMethod)
    }

    private func showLinkSentToEmailPopupAndExit(email: String, isRecoveryEmail: Bool = false) {
        let message = String(format: localized(.resetPasswordEmailPopupMessage), email)
        let buttonTitle = TextConstants.ok

        let popup = PopUpController.with(title: nil, message: message,
                                         image: .custom(Image.forgetPassPopupLock.image), buttonTitle: buttonTitle) { [weak self] popup in
            popup.close()
            self?.trackEmailSentEvent(isRecoveryEmail: isRecoveryEmail)
            self?.navigationController?.popViewController(animated: true)
        }

        popup.open()
    }

    private func navigateToOTP(phoneNumber: String) {
        let viewController = ResetPasswordOTPModuleInitializer.viewController(
            resetPasswordService: resetPasswordService, phoneNumber: phoneNumber
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func navigateToSecurityQuestion(questionId: Int) {
        let viewController = ValidateSecurityQuestionViewController(
            resetPasswordService: resetPasswordService, questionId: questionId
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension IdentityVerificationViewController: ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService, readyToProceedWithMethod method: IdentityVerificationMethod) {
        hideSpinner()
        switch method {
        case let .email(email):
            showLinkSentToEmailPopupAndExit(email: email)
        case let .recoveryEmail(email):
            showLinkSentToEmailPopupAndExit(email: email, isRecoveryEmail: true)
        case let .sms(phoneNumber):
            navigateToOTP(phoneNumber: phoneNumber)
        case let .securityQuestion(id):
            navigateToSecurityQuestion(questionId: id)
        case .unknown:
            break
        }
    }

    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {
        hideSpinner()
        UIApplication.showErrorAlert(message: error.localizedDescription)
    }
}

private extension IdentityVerificationViewController {
    func setupHeader() {
        titleLabel.textColor = AppColor.forgetPassText.color
        titleLabel.font = .appFont(.medium, size: 14)

        descriptionLabel.textColor = AppColor.forgetPassText.color
        descriptionLabel.font = .appFont(.regular, size: 16)

        setupTitleAndDescription()

        tableHeaderView.frame.size = tableHeaderView.systemLayoutSizeFitting(
            CGSize(width: view.frame.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        tableView.tableHeaderView = tableHeaderView
    }

    func setupTitleAndDescription() {
        if resetPasswordService.isInSecondChallenge {
            titleLabel.text = localized(.resetPasswordChallenge2Header)
            descriptionLabel.text = localized(.resetPasswordChallenge2Body)
        } else {
            titleLabel.text = localized(.resetPasswordChallenge1Header)
            descriptionLabel.text = localized(.resetPasswordChallenge1Body)
        }
    }
}

// MARK: Analytics
private extension IdentityVerificationViewController {
    var isInSecondChallenge: Bool { resetPasswordService.isInSecondChallenge }

    func trackScreen() {
        analyticsService.logScreen(screen: isInSecondChallenge ? .identityVerification2Challenge : .identityVerification)

        AnalyticsService.sendNetmeraEvent(
            event: isInSecondChallenge
                ? NetmeraEvents.Screens.FPVerificationMethod2Screen()
                : NetmeraEvents.Screens.FPVerificationMethodScreen()
        )
    }

    func trackContinueEvent(method: IdentityVerificationMethod) {
        guard let label = analyticsLabel(for: method) else { return }

        let action: GAEventAction = isInSecondChallenge ? .verificationMethod2Challenge : .verificationMethod
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: action,
            eventLabel: label
        )

        guard let netmeraMethod = netmeraMethod(for: method) else { return }

        AnalyticsService.sendNetmeraEvent(
            event: isInSecondChallenge
                ? NetmeraEvents.Actions.FPVerificationMethod2(method: netmeraMethod)
                : NetmeraEvents.Actions.FPVerificationMethod(method: netmeraMethod)
        )
    }

    func trackBackEvent() {
        AnalyticsService.sendNetmeraEvent(
            event: isInSecondChallenge
                ? NetmeraEvents.Actions.FPVerificationMethod2Back()
                : NetmeraEvents.Actions.FPVerificationMethodBack()
        )
    }

    func trackEmailSentEvent(isRecoveryEmail: Bool) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .popUp,
            eventActions: isInSecondChallenge ? .forgotPassword2 : .forgotPassword,
            eventLabel: .resetPasswordMethod(isRecoveryEmail ? .recoveryEmail : .email)
        )

        let netmeraMailType: NetmeraEventValues.FPMailType = isRecoveryEmail ? .recoveryEmail : .email
        AnalyticsService.sendNetmeraEvent(
            event: isInSecondChallenge
                ? NetmeraEvents.Actions.FPSentMail2(mailType: netmeraMailType)
                : NetmeraEvents.Actions.FPSentMail(mailType: netmeraMailType)
        )
    }

    // helpers
    func analyticsLabel(for method: IdentityVerificationMethod) -> GAEventLabel? {
        switch method {
        case .email:
            return .resetPasswordMethod(.email)
        case .recoveryEmail:
            return .resetPasswordMethod(.recoveryEmail)
        case .sms:
            return .resetPasswordMethod(.phoneNumber)
        case .securityQuestion:
            return .resetPasswordMethod(.securityQuestion)
        case .unknown:
            return nil
        }
    }

    func netmeraMethod(for method: IdentityVerificationMethod) -> NetmeraEventValues.FPVerificationMethod? {
        switch method {
        case .email:
            return .email
        case .recoveryEmail:
            return .recoveryEmail
        case .sms:
            return .phone
        case .securityQuestion:
            return .securityQuestion
        case .unknown:
            return nil
        }
    }
}
