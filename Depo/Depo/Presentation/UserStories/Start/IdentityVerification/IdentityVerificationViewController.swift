//
//  IdentityVerificationViewController.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class IdentityVerificationViewController: UIViewController {
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
        dataSource.availableMethods = [
            .sms(phone: "053******92"),
            .email(email: "lor*****m@******.com"),
            .recoveryEmail(email: "lor*****m@******.com"),
            .securityQuestion(id: 0)
        ]
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
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
//        tableView.delegate = self
    }
}
