//
//  AutoSyncAutoSyncViewController.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncViewController: UIViewController, AutoSyncViewInput, AutoSyncDataSourceDelegate {

    var output: AutoSyncViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var skipButton: ButtonWithCorner!
    @IBOutlet weak var bacgroundImage: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private lazy var storageVars: StorageVars = factory.resolve()
    
    var fromSettings: Bool = false
    var isFirstTime = true
    
    let dataSource = AutoSyncDataSource()

    // MARK: Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = !fromSettings
        startButton.isHidden = fromSettings
        bacgroundImage.isHidden = fromSettings
        dataSource.isFromSettings = fromSettings
        
        if fromSettings {
            view.backgroundColor = ColorConstants.whiteColor
            navigationBarWithGradientStyle()
        } else {
            view.backgroundColor = UIColor.lrTiffanyBlue
            hidenNavigationBarStyle()
            topConstraint.constant = 64
            view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let settings = dataSource.createAutoSyncSettings()
        output.save(settings: settings)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Device.isIpad, fromSettings {
            setNavigationTitle(title: TextConstants.autoSyncNavigationTitle)
        }
        
        titleLabel.text =  fromSettings ? TextConstants.autoSyncFromSettingsTitle : TextConstants.autoSyncTitle
        titleLabel.font = fromSettings ? UIFont.TurkcellSaturaDemFont(size: 16) : UIFont.TurkcellSaturaDemFont(size: 18)
        titleLabel.textAlignment = .left
        if Device.isIpad {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 22)
            titleLabel.textAlignment = .center
        }
        
        titleLabel.textColor = fromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        
        startButton.setTitle(TextConstants.autoSyncStartUsingLifebox, for: .normal)
        skipButton.setTitle(TextConstants.autoSyncskipForNowButton, for: .normal)
        
        dataSource.setup(table: tableView)
        dataSource.delegate = self
        
        output.viewIsReady()
    }

    // MARK: buttons actions
    
    @IBAction func onStartUsingButton() {
        let settings = dataSource.createAutoSyncSettings()
        
        if !settings.isAutoSyncEnabled {
            MenloworksEventsService.shared.onFirstAutosyncOff()
        }
        storageVars.autoSyncSet = true
        
        output.change(settings: settings)
    }
    
    @IBAction func onSkipButtn() {
        output.skipForNowPressed(onSyncDisabled: { [weak self] in
            self?.storageVars.autoSyncSet = true
            self?.disableAutoSync()
        })
    }

    
    // MARK: AutoSyncViewInput
    func setupInitialState() {
    }
    
    func prepaire(syncSettings: AutoSyncSettings) {
        dataSource.showCells(from: syncSettings)
    }
    
    func reloadTableView() {
        dataSource.reloadTableView()
    }
    
    func disableAutoSync() {
        dataSource.forceDisableAutoSync()
    }
    
    // MARK: AutoSyncDataSourceDelegate
    
    func enableAutoSync() {
        output.enableAutoSync()
    }
    
    func mobileDataEnabledFor(model: AutoSyncModel) {
        if fromSettings, isFirstTime {
            isFirstTime = false
            
            let router = RouterVC()
            let controller = PopUpController.with(title: TextConstants.autoSyncSyncOverTitle,
                                                  message: TextConstants.autoSyncSyncOverMessage,
                                                  image: .none,
                                                  firstButtonTitle: TextConstants.cancel,
                                                  secondButtonTitle: TextConstants.autoSyncSyncOverOn,
                                                  firstAction: { vc in
                                                    model.isSelected = false
                                                    self.tableView.reloadData()
                                                    vc.close()
            })
            router.presentViewController(controller: controller)
        }
    }
    
}
