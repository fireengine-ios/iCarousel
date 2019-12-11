//
//  UserProfileUserProfileInitializer.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserProfileModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, userInfo: AccountInfoResponse, isTurkcellUser: Bool = false) -> UIViewController {
//        let viewController = UserProfileViewController(nibName: nibName, bundle: nil)
        let viewController = UserProfileViewController()
        let configurator = UserProfileModuleConfigurator()
        configurator.configure(viewController: viewController, userInfo: userInfo, isTurkcellUser: isTurkcellUser)
        return viewController
    }

}
