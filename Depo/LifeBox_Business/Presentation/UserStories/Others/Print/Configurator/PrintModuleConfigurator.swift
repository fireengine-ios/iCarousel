//
//  PrintModuleConfigurator.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintModuleConfigurator: NSObject {

    func configure(viewController: PrintViewController, data: [Item]) {
                
        let presenter = PrintPresenter()
        presenter.view = viewController
        
        let interactor = PrintInteractor(data: data)
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.output = presenter
    }
    
}
