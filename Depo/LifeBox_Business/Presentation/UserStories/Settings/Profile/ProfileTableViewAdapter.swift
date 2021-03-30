//
//  ProfileTableViewAdapter.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ProfileTableViewAdapter: NSObject {
    
    //MARK: - Private properties

    private weak var tableView: UITableView?
    private weak var delegate: SettingsTableViewAdapterDelegate?

    private var storageUsageInfo: SettingsStorageUsageResponseItem?
    
    //MARK: - Init

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: SettingsTableViewAdapterDelegate? = nil) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
    }
    
    //MARK: - Public funcs

    func update(with storageUsageData: SettingsStorageUsageResponseItem?) {
        storageUsageInfo = storageUsageData
        reloadContent()
    }
    
    //MARK: - Private funcs
    
    private func setupTableView() {
        tableView?.tableFooterView = UIView()
        tableView?.register(nibCell: ProfileCell.self)
        tableView?.register(nibCell: SettingsStorageTableViewCell.self)
        tableView?.separatorStyle = .none
        tableView?.contentInset = .init(top: 5, left: 0, bottom: 64, right: 0)
    }

    private func reloadContent() {
        tableView?.reloadData()
    }
}

//MARK: - UITableViewDelegate

extension ProfileTableViewAdapter: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 114
        case 1:
            return 100
        default:
            return 0.1
        }
    }
}

//MARK: - UITableViewDataSource

extension ProfileTableViewAdapter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(reusable: ProfileCell.self)
            return cell
        case 1:
            guard let storageUsageInfo = storageUsageInfo else {
//                assertionFailure("storageUsageInfo is nil but cellForRowAt called. Recheck logic")
                return UITableViewCell()
            }
            let cell = tableView.dequeue(reusable: SettingsStorageTableViewCell.self)
            cell.setup(with: storageUsageInfo)
            cell.selectionStyle = .none
            return cell
        default: break
        }

        return UITableViewCell()
    }
}

