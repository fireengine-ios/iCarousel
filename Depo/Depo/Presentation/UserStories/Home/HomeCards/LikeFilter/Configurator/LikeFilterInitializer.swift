//
//  LikeFilterLikeFilterInitializer.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LikeFilterModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var likefilterViewController: LikeFilterViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = LikeFilterViewController(nibName: nibName, bundle: nil)
        let configurator = LikeFilterModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
