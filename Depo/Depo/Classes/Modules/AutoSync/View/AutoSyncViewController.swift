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
    @IBOutlet weak var startButton: UIButton!
    
    let dataSource = AutoSyncDataSource()

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = TextConstants.autoSyncNavigationTitle
        
        titleLabel.text = TextConstants.autoSyncTitle
        titleLabel.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 16)
        titleLabel.textColor = ColorConstants.whiteColor
        
        startButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 20)
        startButton.backgroundColor = ColorConstants.whiteColor
        startButton.setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        startButton.setTitle(TextConstants.autoSyncStartUsingLifebox, for: .normal)
        startButton.layer.cornerRadius = startButton.frame.size.height * 0.5
        
        dataSource.configurateTable(table: tableView)
        
        output.viewIsReady()
    }

    // MARK: buttons actions
    
    @IBAction func onStartUsingButton(){
    
    }

    // MARK: AutoSyncViewInput
    func setupInitialState() {
    }
    
    func preperedCellsModels(models:[AutoSyncModel]){
        dataSource.showCellsFromModels(models: models)
    }
    
}
