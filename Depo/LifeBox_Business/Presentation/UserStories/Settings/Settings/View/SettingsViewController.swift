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
            newValue.layer.borderColor = ColorConstants.Text.labelTitle.cgColor
            newValue.setTitle(TextConstants.settingsPageLogout, for: .normal)
            newValue.setTitleColor(ColorConstants.Text.labelTitle, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        }
    }
    
    @IBOutlet private weak var appVersionLabel: UILabel! {
        willSet {
            newValue.text = appVersion
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 11)
            newValue.textColor = ColorConstants.multifileCellSubtitleText
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
    
    private var appVersion: String {
        let fullAppVersion = "\(SettingsBundleHelper.appVersion()) (\(SettingsBundleHelper.appBuild()))"
        let formattedAppVersion = String(format: TextConstants.appVersion, fullAppVersion)
        return formattedAppVersion
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        settingsTableViewAdapter = SettingsTableViewAdapter(with: tableView, delegate: self)
        output.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        let barStyle = NavigationBarStyles.white
        setNavigationTitle(title: TextConstants.settingsPageTitle, style: barStyle)
        setNavigationBarStyle(barStyle)
        setupCustomButtonAsNavigationBackButton(style: barStyle, asLeftButton: true, title: "", target: self, image: nil, action: nil)
        navigationController?.changeLargeTitle(prefersLargeTitles: false, barStyle: barStyle)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
