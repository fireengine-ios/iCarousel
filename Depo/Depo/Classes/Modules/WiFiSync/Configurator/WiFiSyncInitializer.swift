//
//  WiFiSyncWiFiSyncInitializer.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WiFiSyncModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var wifisyncViewController: WiFiSyncViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = WiFiSyncViewController(nibName: nibName, bundle: nil)
        let configurator = WiFiSyncModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
