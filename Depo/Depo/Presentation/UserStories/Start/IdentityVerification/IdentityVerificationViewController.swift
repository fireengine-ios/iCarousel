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
            newValue.setTitleColor(ColorConstants.whiteColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)
            newValue.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)
        }
    }

    private var dataSource: IdentityVerificationDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)

        dataSource = IdentityVerificationDataSource(tableView: tableView)
        dataSource.availableMethods = availableMethods
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen()
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
    }

    private func showLinkSentToEmailPopupAndExit(email: String, isRecoveryEmail: Bool = false) {
        let message = String(format: localized(.resetPasswordEmailPopupMessage), email)
        let buttonTitle = TextConstants.ok

        let popup = PopUpController.with(title: nil, message: message,
                                         image: .success, buttonTitle: buttonTitle) { [weak self] popup in
            popup.close()
            self?.trackEmailSentEvent(isRecoveryEmail: isRecoveryEmail)
            self?.navigationController?.popViewController(animated: true)
        }

        present(popup, animated: true)
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
        titleLabel.textColor = .lrTealishTwo
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)

        descriptionLabel.textColor = ColorConstants.textGrayColor
        descriptionLabel.font = UIFont.TurkcellSaturaFont(size: 18)

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
    private var isInSecondChallenge: Bool { resetPasswordService.isInSecondChallenge }

    func trackScreen() {
        analyticsService.logScreen(screen: isInSecondChallenge ? .identityVerification2Challenge : .identityVerification)
    }

    func trackContinueEvent(method: IdentityVerificationMethod) {
        guard let label = analyticsLabel(for: method) else { return }

        let action: GAEventAction = isInSecondChallenge ? .verificationMethod2Challenge : .verificationMethod
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: action,
            eventLabel: label
        )
    }

    func trackEmailSentEvent(isRecoveryEmail: Bool) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .popUp,
            eventActions: isInSecondChallenge ? .forgotPassword2 : .forgotPassword,
            eventLabel: .resetPasswordMethod(isRecoveryEmail ? .recoveryEmail : .email)
        )
    }

    private func analyticsLabel(for method: IdentityVerificationMethod) -> GAEventLabel? {
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
}
