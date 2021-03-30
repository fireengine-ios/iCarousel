//
//  ProfileViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ProfileViewController: BaseViewController, NibInit {
    
    //MARK: - Private properties
    
    private var profileTableViewAdapter: ProfileTableViewAdapter?
    
    //MARK: - @IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        setView()
        profileTableViewAdapter = ProfileTableViewAdapter(with: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.profilePageTitle, style: .white)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    //MARK: - Private funcs
    
    private func setView() {
        view.backgroundColor = ColorConstants.settingsTableBackground
    }
}

extension ProfileViewController: SettingsViewInput {
    func prepareCellsData() {

    }

    func updateUserDataUsageSection(usageData: SettingsStorageUsageResponseItem?) {
        profileTableViewAdapter?.update(with: usageData)
    }
}
