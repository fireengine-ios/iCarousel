//
//  NavigationController.swift
//  Depo
//
//  Created by Andrei Novikau on 04/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var statusBarHidden = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return presentedViewController ?? viewControllers.last
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return presentedViewController ?? viewControllers.last
    }
}
