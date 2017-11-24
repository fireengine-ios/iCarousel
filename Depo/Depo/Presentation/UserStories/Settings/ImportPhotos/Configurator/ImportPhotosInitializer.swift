//
//  ImportPhotosInitializer.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ImportPhotosInitializer: NSObject {
    
    var importFromDropboxViewController: ImportPhotosViewController!
    
    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = ImportPhotosViewController(nibName: nibName, bundle: nil)
        let configurator = ImportPhotosConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
