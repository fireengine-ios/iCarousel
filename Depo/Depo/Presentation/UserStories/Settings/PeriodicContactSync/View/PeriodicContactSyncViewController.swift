//
//  PeriodicContactSyncViewController.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PeriodicContactSyncViewController: UIViewController {
    
    var output: PeriodicContactSyncViewOutput!
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    private let dataSource =  PeriodicContactSyncDataSource()
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        titleLabel.text = TextConstants.autoSyncFromSettingsTitle
        
        activityManager.delegate = self
        
        configureNavBar()
        
        dataSource.setup(table: tableView)
        
        output.viewIsReady()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let settings = dataSource.createAutoSyncSettings()
        output.save(settings: settings)
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.periodicContactsSync)
        
        navigationController?.navigationItem.title = TextConstants.backTitle
    }

}

// MARK: - ActivityIndicator

extension PeriodicContactSyncViewController: ActivityIndicator {
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
    
}

// MARK: - FaceImageViewInput

extension PeriodicContactSyncViewController: PeriodicContactSyncViewInput {
    
    func prepaire(syncSettings: AutoSyncSettings) {
        dataSource.showCells(from: syncSettings)
    }
    
    func reloadTableView() {
        dataSource.reloadTableView()
    }
    
}

