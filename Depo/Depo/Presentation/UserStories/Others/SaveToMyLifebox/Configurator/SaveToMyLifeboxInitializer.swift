//
//  SaveToMyLifeboxInitializer.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class SaveToMyLifeboxInitializer: NSObject {
    class func initializeSaveToMyLifeboxViewController(with nibName: String, publicToken: String) -> SaveToMyLifeboxViewController {
        let viewController = SaveToMyLifeboxViewController(nibName: nibName, bundle: nil)
        let configurator = SaveToMyLifeboxConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, publicToken: publicToken)
        return viewController
    }
    
    class func initializeSaveToMyLifeboxViewController(with nibName: String, item: WrapData) -> SaveToMyLifeboxViewController {
        let viewController = SaveToMyLifeboxViewController(nibName: nibName, bundle: nil)
        let configurator = SaveToMyLifeboxConfigurator()
        configurator.configureModuleForInnerFolder(viewInput: viewController, item: item)
        return viewController
    }
}
