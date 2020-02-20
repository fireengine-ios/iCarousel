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
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if #available(iOS 11.0, *) {
            if viewControllers.count > 1,
                let currentController = viewControllers[viewControllers.count - 1] as? ViewController,
                let viewController = viewControllers[viewControllers.count - 2] as? ViewController,
                currentController.preferredNavigationBarStyle != viewController.preferredNavigationBarStyle {
        
                let image = viewController.preferredNavigationBarStyle.backgroundImage
                navigationBar.setBackgroundImage(image, for: .default)
            }
        }
        
        return super.popViewController(animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.checkModalPresentationStyle()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
