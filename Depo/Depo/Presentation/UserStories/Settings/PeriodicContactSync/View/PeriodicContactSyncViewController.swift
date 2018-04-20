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
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        titleLabel.text = TextConstants.autoSyncFromSettingsTitle
        
        activityManager.delegate = self
        
        configureNavBar()
                
        output.viewIsReady(tableView: tableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        output.saveSettings()
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.periodicContactsSync)
        
        navigationController?.navigationItem.title = TextConstants.backTitle
    }

}

// MARK: - PeriodicContactSyncViewInput

extension PeriodicContactSyncViewController: PeriodicContactSyncViewInput {
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
    
}

