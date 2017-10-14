//
//  VideoCellVideoCellInitializer.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class VideoCellModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var videocellViewController: VideoCellViewController!
    
    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = VideoCellViewController(nibName: nibName, bundle: nil)
        let configurator = VideoCellModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
