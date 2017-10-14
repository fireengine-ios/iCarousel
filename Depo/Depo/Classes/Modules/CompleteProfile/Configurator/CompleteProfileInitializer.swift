//
//  CompleteProfileCompleteProfileInitializer.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CompleteProfileModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var completeprofileViewController: CompleteProfileViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = CompleteProfileViewController(nibName: nibName, bundle: nil)
        let configurator = CompleteProfileModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
