//
//  IdentityVerificationViewController.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class IdentityVerificationViewController: BaseViewController {
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
    @IBOutlet private weak var tableView: ResizableTableView!
    @IBOutlet private weak var continueButton: WhiteButtonWithRoundedCorner!

    private var dataSource: IdentityVerificationDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)
        setupHeader()
        setupContinueButton()
        setupTableView()

        dataSource = IdentityVerificationDataSource(tableView: tableView)
        dataSource.availableMethods = availableMethods
    }

    @IBAction private func continueButtonTapped() {
        guard let selectedMethod = dataSource.selectedMethod else { return }

        resetPasswordService.delegate = self
        resetPasswordService.proceedVerification(with: selectedMethod)
        showSpinner()
    }

    private func showLinkSentToEmailPopupAndExit(email: String) {
        let message = String(format: localized(.resetPasswordEmailPopupMessage), email)
        let buttonTitle = TextConstants.ok

        let popup = PopUpController.with(title: nil, message: message,
                                         image: .success, buttonTitle: buttonTitle) { [weak self] popup in
            popup.close()
            self?.navigationController?.popViewController(animated: true)
        }

        present(popup, animated: true)
    }
}

extension IdentityVerificationViewController: ResetPasswordServiceDelegate {
    func resetPasswordService(_ service: ResetPasswordService, verifiedWithMethod method: IdentityVerificationMethod) {
        hideSpinner()
        switch method {
        case let .email(email):
            showLinkSentToEmailPopupAndExit(email: email)
        case let .recoveryEmail(email):
            showLinkSentToEmailPopupAndExit(email: email)
        case .sms:
            break
        case .securityQuestion:
            break
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
        titleLabel.text = localized(.resetPasswordChallenge1Header)

        descriptionLabel.textColor = ColorConstants.textGrayColor
        descriptionLabel.font = UIFont.TurkcellSaturaFont(size: 18)
        descriptionLabel.text = localized(.resetPasswordChallenge1Body)

        tableHeaderView.frame.size = tableHeaderView.systemLayoutSizeFitting(
            CGSize(width: view.frame.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        tableView.tableHeaderView = tableHeaderView
    }

    func setupContinueButton() {
        continueButton.setTitle(localized(.resetPasswordContinueButton), for: .normal)
        continueButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        continueButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        continueButton.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)
        continueButton.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)
    }

    func setupTableView() {
        tableView.alwaysBounceVertical = false
    }
}
