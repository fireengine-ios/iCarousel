//
//  TurkcellUpdaterViewController.swift
//  Depo
//
//  Created by Konstantin on 10/18/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import UIKit


final class TurkcellUpdaterViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startUpdater()
    }
    
    private func startUpdater() {
        UpdaterController.sharedInstance()?.checkUpdateURL(RouteRequests.updaterUrl, preferredLanguageForTitles: nil, parentViewController: self, completionHandler: { action in
            debugLog("UpdaterController: \(action)")
            switch action {
            case .none:
                ///never
                print("UpdaterController: none")
            case .updateFound:
                ///if parentController == nil
                print("UpdaterController: updateFound")
                
            case .updateChosen:
                /// OK or Install
                print("UpdaterController: updateChosen")
                
            case .updateCheckCompleted:
                ///Cancelled or not found or failed
                print("UpdaterController: updateCheckCompleted")
            }
        })
    }
}
