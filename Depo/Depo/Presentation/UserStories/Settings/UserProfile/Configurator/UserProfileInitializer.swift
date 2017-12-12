//
//  UserProfileUserProfileInitializer.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserProfileModuleInitializer: NSObject {

    class func initializeViewController(with nibName:String, userInfo:AccountInfoResponse) -> UIViewController {
        let viewController = UserProfileViewController(nibName: nibName, bundle: nil)
        let configurator = UserProfileModuleConfigurator()
        configurator.configure(viewController: viewController, userInfo: userInfo)
        return viewController
    }

}
