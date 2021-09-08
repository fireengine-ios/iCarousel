//
//  UserProfileUserProfileInitializer.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class UserProfileModuleInitializer: NSObject {

    class func initializeViewController(userInfo: AccountInfoResponse,
                                        isTurkcellUser: Bool = false,
                                        appearAction: UserProfileAppearAction? = nil) -> UIViewController {
        let viewController = UserProfileViewController()
        let configurator = UserProfileModuleConfigurator()
        configurator.configure(viewController: viewController, userInfo: userInfo,
                               isTurkcellUser: isTurkcellUser, appearAction: appearAction)
        return viewController
    }

}
