//
//  PrivateShareAccessTableViewAdapter.swift
//  Depo
//
//  Created by Anton Ignatovich on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol PrivateShareAccessTableViewAdapterDelegate: class {
    func onRoleTapped(sender: UIButton,
                      info: PrivateShareAccessListInfo,
                      _ adapter: PrivateShareAccessTableViewAdapter)
}

final class PrivateShareAccessTableViewAdapter: NSObject {

    private weak var tableView: UITableView?
    private weak var delegate: PrivateShareAccessTableViewAdapterDelegate?

    private var uuid = ""
    private var fileType: FileType = .unknown
    private var contact: SharedContact?
    private var dataSource: [PrivateShareAccessListInfo] = []

    private lazy var headerView: PrivateShareAccessHeaderView = {
        let vview = PrivateShareAccessHeaderView()
        vview.updateTexts(name: contact?.displayName, email: contact?.subject?.email)
        return vview
    }()

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: PrivateShareAccessTableViewAdapterDelegate) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        setupTableView()
    }

    private func setupTableView() {
        tableView?.register(nibCell: PrivateShareAccessItemTableViewCell.self)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.allowsSelection = false
        tableView?.separatorColor = .clear
        tableView?.tableFooterView = UIView()
    }

    func update(with contact: SharedContact?,
                uuid: String,
                fileType: FileType = .unknown,
                and dataSource: [PrivateShareAccessListInfo]) {
        self.uuid = uuid
        self.fileType = fileType
        self.dataSource = dataSource
        self.contact = contact
        reloadContent()
    }

    private func reloadContent() {
        defer {
            tableView?.reloadData()
        }
        headerView.updateTexts(name: contact?.displayName, email: contact?.subject?.email)
    }
}

// MARK: - UITableViewDelegate
extension PrivateShareAccessTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 84
    }
}

// MARK: - UITableViewDataSource
extension PrivateShareAccessTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PrivateShareAccessItemTableViewCell.self, for: indexPath)

        let object = dataSource[indexPath.row]
        if object.object.uuid == uuid {
            cell.setup(with: object, fileType: fileType, isRootItem: true)
        } else {
            cell.setup(with: object, fileType: .folder, isRootItem: false)
        }

        cell.delegate = self
        return cell
    }
}

// MARK: - PrivateShareAccessItemTableViewCellDelegate

extension PrivateShareAccessTableViewAdapter: PrivateShareAccessItemTableViewCellDelegate {
    func onRoleTapped(sender: UIButton, info: PrivateShareAccessListInfo) {
        delegate?.onRoleTapped(sender: sender,
                               info: info,
                               self)
    }
}
