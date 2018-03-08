//
//  DuplicatedContactsInitializer.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactsModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String,
                                        analyzeResponse: [ContactSync.AnalyzedContact],
                                        moduleOutput: DuplicatedContactsModuleOutput?) -> UIViewController {
        
        let viewController = DuplicatedContactsViewController(nibName: nibName, bundle: nil)
        let configurator = DuplicatedContactsModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, analyzeResponse: analyzeResponse, moduleOutput: moduleOutput)
        return viewController
    }

}
