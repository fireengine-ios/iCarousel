//
//  NavigationController.swift
//  Depo
//
//  Created by Andrei Novikau on 04/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.checkModalPresentationStyle()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
