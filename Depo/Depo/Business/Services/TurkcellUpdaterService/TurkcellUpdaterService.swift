//
//  TurkcellUpdaterService.swift
//  Depo
//
//  Created by Konstantin on 10/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class TurkcellUpdaterService {
    
    func startUpdater(controller: UIViewController?, completion: @escaping VoidHandler) {
        UpdaterController.sharedInstance()?.checkUpdateURL(RouteRequests.updaterUrl(), preferredLanguageForTitles: nil, parentViewController: controller, completionHandler: { action in
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
            
            completion()
        })
    }
    
}
