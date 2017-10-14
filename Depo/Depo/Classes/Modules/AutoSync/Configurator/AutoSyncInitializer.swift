//
//  AutoSyncAutoSyncInitializer.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoSyncModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var autosyncViewController: AutoSyncViewController!

    override func awakeFromNib() {

        let configurator = AutoSyncModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: autosyncViewController)
    }
    
    func setupVC() {
        let configurator = AutoSyncModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: autosyncViewController)
    }
    
    class func initializeViewController(with nibName:String, fromSettings: Bool = false) -> UIViewController {
        let viewController = AutoSyncViewController(nibName: nibName, bundle: nil)
        let configurator = AutoSyncModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, fromSettings: fromSettings)
        return viewController
    }

}
