//
//  PrivateShareContactTableViewAdapter.swift
//  Depo
//
//  Created by Anton Ignatovich on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol PrivateShareContactTableViewAdapterDelegate: class {
    func didTapOnContact(_ contact: SharedContact, adapter: PrivateShareContactTableViewAdapter)
}

final class PrivateShareContactTableViewAdapter: NSObject {

    private weak var tableView: UITableView?
    private weak var delegate: PrivateShareContactTableViewAdapterDelegate?

    private var dataSource: [SharedContact] = []
    private var allowedToEditRoles: Bool = false

    private lazy var transparentHeaderView: UIView = {
        let vview =  UIView()
        vview.backgroundColor = .clear
        return vview
    }()

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: PrivateShareContactTableViewAdapterDelegate) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        setupTableView()
    }

    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        tableView?.register(nibCell: PrivateShareSharedContactTableViewCell.self)
        tableView?.separatorColor = .clear
    }

    func update(with entity: SharedFileInfo) {
        allowedToEditRoles = entity.permissions?.granted?.contains(.writeAcl) ?? false
        dataSource = entity.members ?? []
        reloadContent()
    }

    private func reloadContent() {
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension PrivateShareContactTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return transparentHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard
            allowedToEditRoles,
            dataSource.count > indexPath.row
        else {
            return
        }
        delegate?.didTapOnContact(dataSource[indexPath.row], adapter: self)
    }
}

// MARK: - UITableViewDataSource
extension PrivateShareContactTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PrivateShareSharedContactTableViewCell.self), for: indexPath)
        (cell as? PrivateShareSharedContactTableViewCell)?.setup(with: dataSource[indexPath.row],
                                                                 hasPermissionToEditRole: allowedToEditRoles,
                                                                 isFirstCell: indexPath.row == 0)
        return cell
    }
}
