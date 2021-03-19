//
//  SettingsSettingsViewController.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    func goToFAQ()
    
    func goToAgreements()
        
    func goToActivityTimeline()
    
    func goToPermissions()
    
    func goToPasscodeSettings(isTurkcell: Bool, inNeedOfMail: Bool, needPopPasscodeEnterVC: Bool)
}

final class SettingsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var logoutButton: UIButton! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.borderWidth = 2
            newValue.layer.borderColor = ColorConstants.infoPageValueText.cgColor
            newValue.setTitle(TextConstants.settingsPageLogout, for: .normal)
            newValue.setTitleColor(ColorConstants.infoPageValueText, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        }
    }

    private var settingsTableViewAdapter: SettingsTableViewAdapter!
    
    var output: SettingsViewOutput!

    private let userInfoSubView = UserInfoSubViewModuleInitializer.initializeViewController()
    
    weak var settingsDelegate: SettingsDelegate?
    
    private var isFromPhotoPicker = false
    
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    
    private var cellTypes = [[SettingsTypes]]() {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false)
        settingsTableViewAdapter = SettingsTableViewAdapter(with: tableView, delegate: self)
        output.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        setNavigationTitle(title: TextConstants.settingsPageTitle)
        setNavigationBarStyle(.white)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }

    override func showSpinner() {
        super.showSpinner()
        tableView.isHidden = true
    }

    override func hideSpinner() {
        super.hideSpinner()
        tableView.isHidden = false
    }

    @IBAction func logoutButtonDidPress(_ sender: UIButton) {
        output.onLogout()
    }
}

// MARK: - SettingsViewInput
extension SettingsViewController: SettingsViewInput {
    func prepareCellsData() {

    }

    func updateUserDataUsageSection(usageData: SettingsStorageUsageResponseItem?) {
        guard let usageData = usageData else { return }
        settingsTableViewAdapter.update(with: usageData)
    }
}

// MARK: - SettingsTableViewAdapterDelegate
extension SettingsViewController: SettingsTableViewAdapterDelegate {
    func navigateToProfile(_ adapter: SettingsTableViewAdapter) {
        output.navigateToProfile()
    }

    func navigateToFAQ(_ adapter: SettingsTableViewAdapter) {
        output.navigateToFAQ()
    }

    func navigateToTrashBin(_ adapter: SettingsTableViewAdapter) {
        output.navigateToTrashBin()
    }

    func navigateToContactUs(_ adapter: SettingsTableViewAdapter) {
        output.navigateToContactUs()
    }

    func navigateToAgreements(_ adapter: SettingsTableViewAdapter) {
        output.navigateToAgreements()
    }
}
