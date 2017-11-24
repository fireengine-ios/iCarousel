//
//  PhotoCellPhotoCellInitializer.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoCellModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var photocellViewController: PhotoCellViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = PhotoCellViewController(nibName: nibName, bundle: nil)
        let configurator = PhotoCellModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
