//
//  LocalAlbumModuleInitializer.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LocalAlbumModuleInitializer: BaseFilesGreedModuleInitializer {
    
    class func initializeLocalAlbumsController(with nibName: String) -> UIViewController {
        let viewController = LocalAlbumViewController(nibName: nibName, bundle: nil)
        let configurator = LocalAlbumConfigurator()
        
        configurator.configure(viewController: viewController)
        
        viewController.mainTitle = TextConstants.uploadPhotos

        return viewController
    }
    
}
