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
    
    static func showOnTabBar(errorMessage: String) {
        let errorPopUpVC = PopUpController.with(errorMessage: errorMessage)
        DispatchQueue.toMain {
            RouterVC().tabBarVC?.present(errorPopUpVC, animated: false, completion: nil)
        }
    }
    
    static func showErrorAlert(message: String) {
        guard message != TextConstants.errorBadConnection else {
            return
        }
        let controller = topController()
        if controller is PopUpController {
            return
        }
        let vc = PopUpController.with(title: TextConstants.errorAlert, message: message, image: .error, buttonTitle: TextConstants.ok)
        DispatchQueue.toMain {
            controller?.present(vc, animated: false, completion: nil)
        }
    }
    
    static func showSuccessAlert(message: String) {
        let vc = PopUpController.with(title: TextConstants.success, message: message, image: .success, buttonTitle: TextConstants.ok)
        DispatchQueue.toMain {
            topController()?.present(vc, animated: false, completion: nil)
        }
    }
    
    var statusBarView: UIView? {
        if #available(iOS 13, *) {
            let tag = 31415926
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            }
            
            let newStatusBar = UIView(frame: UIApplication.shared.statusBarFrame)
            newStatusBar.tag = tag
            self.keyWindow?.addSubview(newStatusBar)
            return newStatusBar
            
        } else {
            return value(forKey: "statusBar") as? UIView
        }
    }

}
