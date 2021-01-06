//
//  UserInfoSubViewUserInfoSubViewInitializer.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserInfoSubViewModuleInitializer: NSObject {

    class func initializeViewController() -> UserInfoSubViewViewController {
        let viewController = UserInfoSubViewViewController.initFromNib()
        let configurator = UserInfoSubViewModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }

}
