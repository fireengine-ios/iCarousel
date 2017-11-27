//
//  UserInfoSubViewUserInfoSubViewInitializer.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserInfoSubViewModuleInitializer: NSObject {

    //Connect with object on storyboard
    var userinfosubviewViewController: UserInfoSubViewViewController!

    class func initializeViewController(with nibName:String) -> UIViewController {
        let viewController = UserInfoSubViewViewController(nibName: nibName, bundle: nil)
        let configurator = UserInfoSubViewModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
