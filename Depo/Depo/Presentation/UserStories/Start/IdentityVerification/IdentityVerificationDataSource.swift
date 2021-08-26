//
//  IdentityVerificationDataSource.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class IdentityVerificationDataSource: NSObject {
    weak var tableView: UITableView?
    var availableMethods: [ResetPassword.Method] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    private override init() {
        availableMethods = []
        super.init()
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.register(nibCell: VerificationMethodTableViewCell.self)
        tableView.dataSource = self
    }
}

extension IdentityVerificationDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let method = availableMethods[indexPath.item]

        let cell = tableView.dequeue(reusable: VerificationMethodTableViewCell.self, for: indexPath)
        switch method {
        case let .email(email):
            cell.methodNameLabel.text = "E-posta"
            cell.contentLabel.text = email

        case let .recoveryEmail(email):
            cell.methodNameLabel.text = "Kurtarma E- posta"
            cell.contentLabel.text = email

        case let .sms(phone):
            cell.methodNameLabel.text = "Telefon Numarası"
            cell.contentLabel.text = phone

        case .securityQuestion:
            cell.methodNameLabel.text = "Güvenlik Sorusu"
            cell.contentLabel.text = ""

        case .unknown:
            assertionFailure()
        }

        return cell
    }
}
