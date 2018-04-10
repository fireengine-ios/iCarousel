//
//  UIApplication+topController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/17/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func topController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topController(controller: presented)
        }
        return controller
    }
    
    static func showOnTabBar(errorMessage: String?) {
        let errorPopUpVC = PopUpController.with(errorMessage: errorMessage ?? TextConstants.errorUnrecognizedOccured)
        RouterVC().tabBarVC?.present(errorPopUpVC, animated: false, completion: nil)
    }
    
    static func showErrorAlert(message: String) {
        let controller = topController()
        if controller is PopUpController {
            return
        }
        let vc = PopUpController.with(title: TextConstants.errorAlert, message: message, image: .error, buttonTitle: TextConstants.ok)
        controller?.present(vc, animated: false, completion: nil)
    }
    
    static func showSuccessAlert(message: String) {
        let vc = PopUpController.with(title: TextConstants.success, message: message, image: .success, buttonTitle: TextConstants.ok)
        topController()?.present(vc, animated: false, completion: nil)
    }
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }

}
