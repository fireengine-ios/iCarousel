//
//  AutoSyncAutoSyncViewController.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncViewController: BaseViewController {
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
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var dataSource = AutoSyncDataSource(tableView: tableView, delegate: self)
    
    var fromSettings: Bool = false
    private var onStartUsingButtonTapped = false
    
    private let analyticsManager: AnalyticsService = factory.resolve()//FIXME: Idealy we should send all events to presenter->Interactor and then track it(because tracker is a service) OR just rewrite this module to MVC
    

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Device.isIpad, fromSettings {
            setNavigationTitle(title: TextConstants.autoSyncNavigationTitle)
        }
        
        analyticsService.logScreen(screen: fromSettings ? .autoSyncSettings : .autosyncSettingsFirst)
        analyticsService.trackDimentionsEveryClickGA(screen: fromSettings ? .autoSyncSettings : .autosyncSettingsFirst)
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataSource.isFromSettings = fromSettings
        
        if fromSettings {
            navigationBarWithGradientStyle()
            startButton.isHidden = true
        } else {
            navigationItem.hidesBackButton = true
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if fromSettings {
            storageVars.autoSyncSet = true
            output.save(settings: dataSource.autoSyncSetting, selectedAlbums: dataSource.selectedAlbums)
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
        titleLabel.text = TextConstants.autoSyncFromSettingsTitle
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        if Device.isIpad {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 22)
            titleLabel.textAlignment = .center
        } else {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
            titleLabel.textAlignment = .left
        }
        
        view.addSubview(titleLabel)
        titleLabel.pinToSuperviewEdges(offset: 20)

        let size = view.sizeToFit(width: tableView.bounds.width)
        view.frame.size = size
    
        tableView.tableHeaderView = view
        
        let back = UIView(frame: tableView.bounds)
        back.backgroundColor = .white
        tableView.backgroundView = back
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    // MARK: buttons actions
    
    @IBAction func onStartUsingButton() {
        onStartUsingButtonTapped = true
        
        storageVars.autoSyncSet = true
        output.change(settings: dataSource.autoSyncSetting, selectedAlbums: dataSource.selectedAlbums)
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
            output.save(settings: dataSource.autoSyncSetting, selectedAlbums: dataSource.selectedAlbums)
        }
    }

    func checkPermissionsSuccessed() {
        analyticsService.track(event: .turnOnAutosync)
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
                self.present(controller, animated: true, completion: nil)
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
           self.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - AutoSyncDataSourceDelegate

extension AutoSyncViewController: AutoSyncDataSourceDelegate {
    func checkForEnableAutoSync() {
        output.checkPermissions()
    }

    func didChangeSettingsOption(settings: AutoSyncSetting) {
        let eventAction: GAEventAction
        if fromSettings {
            eventAction = .settingsAutoSync
        } else {
            eventAction = .firstAutoSync
        }
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: eventAction, eventLabel: GAEventLabel.getAutoSyncSettingEvent(autoSyncSettings: settings))
    }
}
 
