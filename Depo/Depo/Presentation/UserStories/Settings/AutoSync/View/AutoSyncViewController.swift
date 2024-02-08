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
    
    @IBOutlet private weak var startButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(TextConstants.autoSyncStartUsingLifebox, for: .normal)
            newValue.isOpaque = true
        }
    }
    
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(closeSelf))
    
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var dataSource = AutoSyncDataSource(tableView: tableView, delegate: self, delegateContact: self)
    private lazy var activityManager = ActivityIndicatorManager()
    private let router = RouterVC()
    
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
        
        setup()
        dataSource.isFromSettings = fromSettings
        
        if fromSettings {
            startButton.isHidden = true
        } else {
            navigationItem.hidesBackButton = true
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupTableHeaderView()
        }
    }
    
    private func setup() {
        navigationItem.leftBarButtonItem = closeSelfButton
    }
    
    @objc private func closeSelf() {
        if fromSettings {
            output.checkPermissionsForFromSettings(success: { [weak self] in
                self?.dataSource.setSyncOperationForAutoSyncSwither()
                self?.storageVars.isAutoSyncSet = true
                self?.setSave()
                self?.navigationController?.popViewController(animated: true)
            })
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    private func setSave() {
        output.save(settings: dataSource.autoSyncSetting, albums: dataSource.autoSyncAlbums)
    }
    
    private func setupTableHeaderView() {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var text = TextConstants.autoSyncFromSettingsTitle as NSString
        if !text.components(separatedBy: ".").isEmpty {
            text = text.components(separatedBy: ".")[0] as NSString
        }
        
        if text.contains(" \n\n") {
            let attributedString = NSMutableAttributedString(string: text as String,
                                                             attributes: [.font: UIFont.appFont(.medium, size: 14.0),
                                                                          .foregroundColor: AppColor.label.color])
            
            let range = text.range(of: " \n\n")
            let startRange = (text as NSString).range(of: " \n\n")
            let endRange = NSRange(location: range.location + range.length, length: text.length - range.location - range.length)
            
            attributedString.addAttribute(.font, value: UIFont.appFont(.medium, size: 14.0), range: startRange )
            attributedString.addAttribute(.font, value: UIFont.appFont(.medium, size: 12.0), range: endRange )
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.text = "\(text)."
            titleLabel.font = .appFont(.medium, size: 14)
        }
        

        
        titleLabel.textColor = AppColor.label.color
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.pinToSuperviewEdges(offset: 8)
        
        let size = view.sizeToFit(width: tableView.bounds.width)
        view.frame.size = size
        
        view.backgroundColor = .clear
        
        tableView.tableHeaderView = view
    }
    
    // MARK: buttons actions
    
    @IBAction func onStartUsingButton() {
        if dataSource.isAutoSyncSwitchSelected {
            output.checkPermissionsForFromSettings(success: { [weak self] in
                self?.startApp()
            })
        } else {
            startApp()
        }
    }
    
    private func startApp() {
        dataSource.setSyncOperationForAutoSyncSwither()
        let isFirstLoginControl = storageVars.highlightedIsFirstLogin
        
        NetmeraService.updateUser()
        
        if !isFirstLoginControl {
            let popup = PopUpController.with(title: nil, message: localized(.syncPageOfferPopUp), image: .none, firstButtonTitle: TextConstants.noForUpgrade, secondButtonTitle: TextConstants.faceImageYes,
                firstAction: { [weak self] vc in
                    self?.setAutoSyncSetting()
                },
                secondAction: { vc in
                    self.dismiss(animated: false, completion: {
                        DispatchQueue.toMain { [weak self] in
                            self?.storageVars.highlightedPopUpPackageBack = true
                            self?.setAutoSyncSetting()
                            self?.router.pushViewController(viewController: (self?.router.myStorage(usageStorage: nil))!)
                        }
                    })
                })
            popup.open()
        } else {
            setAutoSyncSetting()
        }
        storageVars.highlightedIsFirstLogin = true
    }
    
    private func setAutoSyncSetting() {
        onStartUsingButtonTapped = true
        storageVars.isAutoSyncSet = true
        output.change(settings: dataSource.autoSyncSetting, albums: dataSource.autoSyncAlbums)
    }
}

// MARK: - AutoSyncViewInput

extension AutoSyncViewController: AutoSyncViewInput {
    
    func forceDisableAutoSyncContact() {
        dataSource.forceDisableAutoSyncContact()
    }
    
    func createAutoSyncSettings() -> PeriodicContactsSyncSettings {
        dataSource.createAutoSyncSettings()
    }
    
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
    
    func showCells(from syncSettings: PeriodicContactsSyncSettings) {
        dataSource.showCells(from: syncSettings)
    }
    
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

extension AutoSyncViewController: PeriodicContactSyncDataSourceDelegate {
    func onValueChanged() {
        output.onValueChangeContact()
    }
}

