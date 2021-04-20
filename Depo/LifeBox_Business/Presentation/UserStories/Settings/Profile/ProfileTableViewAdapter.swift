//
//  ProfileTableViewAdapter.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol ProfileDelegate: class {
    func showActivityIndicator()
    func hideActivityIndicator()
}

final class ProfileTableViewAdapter: NSObject {
    
    //MARK: - Public properties
    
    weak var profileDelegate: ProfileDelegate?
    
    //MARK: - Private properties

    private weak var tableView: UITableView?
    private weak var delegate: ProfileDelegate?

    private var storageUsageInfo: SettingsStorageUsageResponseItem?
    
    //MARK: - Init

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: ProfileDelegate) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        setupTableView()
        getStorageUsageInfo()
    }
    
    //MARK: - Private funcs
    
    private func setupTableView() {
        tableView?.tableFooterView = UIView()
        tableView?.register(nibCell: ProfileCell.self)
        tableView?.register(nibCell: SettingsStorageTableViewCell.self)
        tableView?.backgroundColor = ColorConstants.settingsTableBackground
        tableView?.separatorStyle = .none
        tableView?.contentInset = .init(top: 0, left: 0, bottom: 64, right: 0)
        
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    private func reloadContent() {
        tableView?.reloadData()
        delegate?.hideActivityIndicator()
    }
    
    private func getStorageUsageInfo() {
        delegate?.showActivityIndicator()
        let userAccountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
        let organizationUUID = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid ?? ""
        SingletonStorage.shared.getStorageUsageInfo(projectId: organizationUUID, userAccountId: userAccountUuid, success: { [weak self] info in
            self?.storageUsageInfo = info
            self?.reloadContent()
        }, fail: { [weak self] errorResponse in
            self?.storageUsageInfo = nil
            self?.reloadContent()
        })
    }
}

//MARK: - UITableViewDelegate

extension ProfileTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 118
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
        guard storageUsageInfo != nil else {
            return 1
        }
        
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
                return UITableViewCell()
            }
            let cell = tableView.dequeue(reusable: SettingsStorageTableViewCell.self)
            cell.setup(with: storageUsageInfo, isProfilePage: true)
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}

