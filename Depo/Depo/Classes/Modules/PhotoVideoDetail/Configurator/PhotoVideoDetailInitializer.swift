//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoDetailModuleInitializer: NSObject {

    //Connect with object on storyboard
    var photovideodetailViewController: PhotoVideoDetailViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .info, .edit, .delete],
                                               style: .blackOpaque, tintColor: nil)
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoVideoDetailModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController, bottomBarConfig: bottomBarConfig)
        return viewController
    }
}
