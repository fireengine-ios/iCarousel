//
//  AutoSyncAutoSyncViewController.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class AutoSyncViewController: BaseViewController, NibInit {
    var output: AutoSyncViewOutput!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var startButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.autoSyncStartUsingLifebox, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = ApplicationPalette.bigRoundButtonFont
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
    
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var dataSource = AutoSyncDataSource(tableView: tableView, delegate: self)
    
    var fromSettings: Bool = false
    private var onStartUsingButtonTapped = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Device.isIpad, fromSettings {
            setNavigationTitle(title: TextConstants.autoSyncNavigationTitle)
        }
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource.isFromSettings = fromSettings
        
        if fromSettings {
            startButton.isHidden = true
        } else {
            navigationItem.hidesBackButton = true
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if fromSettings {
            storageVars.isAutoSyncSet = true
            output.save(settings: dataSource.autoSyncSetting, albums: dataSource.autoSyncAlbums)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupTableHeaderView()
        }
    }
    
    private func setupTableHeaderView() {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let text = TextConstants.autoSyncFromSettingsTitle as NSString
        
        let attributedString = NSMutableAttributedString(string: text as String,
                                                         attributes: [.font: UIFont.appFont(.regular, size: 14.0),
                                                                      .foregroundColor: AppColor.label.color])
        
        let range = text.range(of: " \n\n")
        let startRange = (text as NSString).range(of: " \n\n")
        let endRange = NSRange(location: range.location + range.length, length: text.length - range.location - range.length)
        
        attributedString.addAttribute(.font, value: UIFont.appFont(.medium, size: 14.0), range: startRange )
        attributedString.addAttribute(.font, value: UIFont.appFont(.regular, size: 12.0), range: endRange )
        titleLabel.attributedText = attributedString
        
        titleLabel.textColor = AppColor.label.color
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.pinToSuperviewEdges(offset: 20)
        
        let size = view.sizeToFit(width: tableView.bounds.width)
        view.frame.size = size
        
        tableView.tableHeaderView = view
    }
    
    // MARK: buttons actions
    
    @IBAction func onStartUsingButton() {
        onStartUsingButtonTapped = true
        
        storageVars.isAutoSyncSet = true
        output.change(settings: dataSource.autoSyncSetting, albums: dataSource.autoSyncAlbums)
    }
    
}

// MARK: - AutoSyncViewInput

extension AutoSyncViewController: AutoSyncViewInput {
    
    
    func setupInitialState() {
    }
    
    func prepaire(syncSettings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        dataSource.setupModels(with: syncSettings, albums: albums)
    }
    
    func disableAutoSync() {
        dataSource.forceDisableAutoSync()
        if !fromSettings {
            output.save(settings: dataSource.autoSyncSetting, albums: dataSource.autoSyncAlbums)
        }
    }
    
    func checkPermissionsSuccessed() {
        dataSource.checkPermissionsSuccessed()
    }
    
    func checkPermissionsFailedWith(error: String) {
        showAccessAlert(message: error)
    }
    
    func showLocationPermissionPopup(completion: @escaping VoidHandler) {
        guard onStartUsingButtonTapped else {
            let controller = PopUpController.with(title: TextConstants.errorAlert,
                                                  message: TextConstants.locationServiceDisable,
                                                  image: .error,
                                                  buttonTitle: TextConstants.ok) { (vc) in
                vc.close {
                    completion()
                }
            }
            DispatchQueue.toMain {
                controller.open()
            }
            return
        }
        completion()
    }
    
    private func showAccessAlert(message: String) {
        debugLog("AutoSyncViewController showAccessAlert")
        
        let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                              message: message,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                              secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                              secondAction: { vc in
            vc.close {
                UIApplication.shared.openSettings()
            }
        })
        DispatchQueue.toMain {
            controller.open()
        }
    }
}

// MARK: - AutoSyncDataSourceDelegate

extension AutoSyncViewController: AutoSyncDataSourceDelegate {
    func checkForEnableAutoSync() {
        output.checkPermissions()
    }
    
    func didChangeSettingsOption(settings: AutoSyncSetting) {
        output.didChangeSettingsOption(settings: settings)
    }
}

