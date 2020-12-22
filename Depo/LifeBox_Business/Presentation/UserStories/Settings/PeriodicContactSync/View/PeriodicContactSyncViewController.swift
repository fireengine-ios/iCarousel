//
//  PeriodicContactSyncViewController.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PeriodicContactSyncViewController: ViewController {
    
    var output: PeriodicContactSyncViewOutput!
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private lazy var activityManager = ActivityIndicatorManager()
        
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = TextConstants.periodContactSyncFromSettingsTitle
        titleLabel.textColor = ColorConstants.textGrayColor

        if Device.isIpad {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 22)
            titleLabel.textAlignment = .center
        } else {
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
            titleLabel.textAlignment = .left
            setNavigationTitle(title: TextConstants.periodicContactsSync)
        }
        
        activityManager.delegate = self
                        
        output.viewIsReady(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        output.saveSettings()
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.backTitle)
        navigationBarWithGradientStyle()
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

