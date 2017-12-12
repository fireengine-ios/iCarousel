//
//  AutoSyncAutoSyncViewController.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncViewController: UIViewController, AutoSyncViewInput {

    var output: AutoSyncViewOutput!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var skipButton: ButtonWithCorner!
    @IBOutlet weak var tableHConstaint: NSLayoutConstraint!
    @IBOutlet weak var bacgroundImage: UIImageView!
    
    var fromSettings: Bool = false
    
    var saveBarButton: UIBarButtonItem? = nil
    
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
        }
        
        if fromSettings {
            saveBarButton = UIBarButtonItem(title: TextConstants.autoSyncSaveButton,
                                            style: .plain,
                                            target: self,
                                            action: #selector(onSaveButton))
            saveBarButton!.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
            
            splitViewController?.navigationController?.viewControllers.last?.navigationItem.rightBarButtonItem = saveBarButton!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if fromSettings {
            navigationItem.rightBarButtonItem = saveBarButton!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.autoSyncNavigationTitle)
        }
        
        titleLabel.text = TextConstants.autoSyncTitle
        titleLabel.font = fromSettings ? UIFont.TurkcellSaturaDemFont(size: 16) : UIFont.TurkcellSaturaDemFont(size: 18)
        titleLabel.textAlignment = .left
        if Device.isIpad {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 22)
            titleLabel.textAlignment = .center
        }
        
        titleLabel.textColor = fromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        
        startButton.setTitle(TextConstants.autoSyncStartUsingLifebox, for: .normal)
        skipButton.setTitle(TextConstants.autoSyncskipForNowButton, for: .normal)
        
        dataSource.configurateTable(table: tableView, tableHConstraint: tableHConstaint)
        
        output.viewIsReady()
    }

    // MARK: buttons actions
    
    @IBAction func onStartUsingButton(){
        let model = dataSource.createSettingsAutoSyncModel()
        output.onSaveButton(setting: model)
        
        output.startLifeBoxPressed()
    }
    
    @IBAction func onSkipButtn(){
        output.skipForNowPressed()
    }

    // MARK: AutoSyncViewInput
    func setupInitialState() {
    }
    
    func preperedCellsModels(models:[AutoSyncModel]){
        dataSource.showCellsFromModels(models: models)
    }
    
    @objc func onSaveButton(){
        let model = dataSource.createSettingsAutoSyncModel()
        output.onSaveButton(setting: model)
    }
}
