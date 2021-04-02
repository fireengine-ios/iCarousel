//
//  SettingsTableViewAdapter.swift
//  Depo
//
//  Created by Anton Ignatovich on 12.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsTableViewAdapterDelegate: class {
    func navigateToProfile(_ adapter: SettingsTableViewAdapter)
    func navigateToFAQ(_ adapter: SettingsTableViewAdapter)
    func navigateToTrashBin(_ adapter: SettingsTableViewAdapter)
    func navigateToContactUs(_ adapter: SettingsTableViewAdapter)
    func navigateToAgreements(_ adapter: SettingsTableViewAdapter)
}

final class SettingsTableViewAdapter: NSObject {

    private weak var tableView: UITableView?
    private weak var delegate: SettingsTableViewAdapterDelegate?

    private let menuItems: [SettingsMenuItem] = [
        .profile,
        .agreements,
        .faq,
        .contactUs,
        .deletedFiles
    ]
    private var storageUsageInfo: SettingsStorageUsageResponseItem?

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: SettingsTableViewAdapterDelegate) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
    }

    private func setupTableView() {
        tableView?.tableFooterView = UIView()
        tableView?.register(nibCell: SettingsMenuItemTableViewCell.self)
        tableView?.register(nibCell: SettingsStorageTableViewCell.self)
        tableView?.separatorStyle = .none
        tableView?.contentInset = .init(top: 5, left: 0, bottom: 64, right: 0)
    }

    func update(with storageUsageData: SettingsStorageUsageResponseItem?) {
        storageUsageInfo = storageUsageData
        reloadContent()
    }

    private func reloadContent() {
        tableView?.reloadData()
    }
}

extension SettingsTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 102
        case 1:
            return 57
        default:
            return 0.1
        }
    }
}

extension SettingsTableViewAdapter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return storageUsageInfo != nil ? 1 : 0
        case 1:
            return menuItems.count
        default:
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let storageUsageInfo = storageUsageInfo else {
                assertionFailure("storageUsageInfo is nil but cellForRowAt called. Recheck logic")
                return UITableViewCell()
            }
            let cell = tableView.dequeue(reusable: SettingsStorageTableViewCell.self)
            cell.setup(with: storageUsageInfo)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeue(reusable: SettingsMenuItemTableViewCell.self)
            cell.setup(with: menuItems[indexPath.row], isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == menuItems.count - 1)
            cell.selectionStyle = .none
            return cell
        default: break
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else {
            return
        }
        switch menuItems[indexPath.row] {
        case .profile:
            delegate?.navigateToProfile(self)
        case .agreements:
            delegate?.navigateToAgreements(self)
        case .contactUs:
            delegate?.navigateToContactUs(self)
        case .faq:
            delegate?.navigateToFAQ(self)
        case .deletedFiles:
            delegate?.navigateToTrashBin(self)
        }
    }
}
