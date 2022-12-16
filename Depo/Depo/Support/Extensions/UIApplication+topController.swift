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
        // checking !presented.isBeingDismissed
        // for cases where we're presenting while the top view controller is being dimissed
        // example for this is in
        // Gallery screen --> select photos --> three dots button --> share --> copy public link
        if let presented = controller?.presentedViewController, !presented.isBeingDismissed {
            return topController(controller: presented)
        }
        return controller
    }
    
    static func showOnTabBar(errorMessage: String) {
        let errorPopUpVC = PopUpController.with(errorMessage: errorMessage)
        DispatchQueue.toMain {
            errorPopUpVC.open()
        }
    }
    
    static func showCustomAlert(title: String,
                                message: String,
                                image: PopUpImage,
                                buttonTitle: String,
                                closed: (() -> Void)? = nil) {
        debugLog("showCustomAlert \(title) - \(message)")
        guard message != TextConstants.errorBadConnection else {
            return
        }
        let controller = topController()
        if controller is PopUpController {
            return
        }
        let vc = PopUpController.with(title: title, message: message, image: image, buttonTitle: buttonTitle) { vc in
            vc.close {
                closed?()
            }
        }
        
        DispatchQueue.toMain {
            vc.open()
        }
    }
    
    static func showErrorAlert(message: String, closed: (() -> Void)? = nil) {
        debugLog("showErrorAlert \(message)")
        guard message != TextConstants.errorBadConnection else {
            return
        }
        let controller = topController()
        if controller is PopUpController {
            return
        }
        let vc = PopUpController.with(title: TextConstants.errorAlert, message: message, image: .error, buttonTitle: TextConstants.ok) { vc in
            vc.close {
                closed?()
            }
        }
        
        DispatchQueue.toMain {
            vc.open()
        }
    }
    
    static func showSuccessAlert(message: String, closed: (() -> Void)? = nil) {
        let vc = PopUpController.with(title: TextConstants.success, message: message, image: .success, buttonTitle: TextConstants.ok) { vc in
            vc.close {
                closed?()
            }
        }
        DispatchQueue.toMain {
            vc.open()
        }
    }
}
