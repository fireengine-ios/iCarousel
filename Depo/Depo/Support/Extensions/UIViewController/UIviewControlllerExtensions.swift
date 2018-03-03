//
//  UIviewControlllerExtensions.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

//MARK:- WAITING

protocol Waiting {
    
    func showSpiner()
    
    func showSpinnerOnView(_ view: UIView)
    
    func showSpinerIncludeNavigatinBar()
    
    func showSpinerWithCancelClosure(_ cancel: @escaping VoidHandler)
    
    func hideSpinerIncludeNavigatinBar()
    
    func hideSpiner()
    
    func hideSpinerForView(_ view: UIView)
}

extension UIViewController: Waiting {
    
    func showSpinerWithCancelClosure(_ cancel: @escaping VoidHandler) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.backgroundView.color = ColorConstants.whiteColor.withAlphaComponent(0.88)
            let gestureRecognizer = TapGestureRecognizerWithClosure(closure: { [weak self] in
                cancel()
                self?.hideSpinerIncludeNavigatinBar()
            })
            hud.backgroundView.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func showSpiner() {
        DispatchQueue.main.async {
            _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func showSpinnerOnView(_ view: UIView) {
        DispatchQueue.main.async {
            _ = MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    func showSpinerIncludeNavigatinBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            window.addSubview(hud)
        }
    }
    
    func hideSpinerIncludeNavigatinBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            MBProgressHUD.hide(for: window, animated: true)
        }
    }
    
    func hideSpiner() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func hideSpinerForView(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}


//MARK:- CustomNavController

protocol CurrentNavController {
    var currentNavController: UINavigationController? { get }
}

extension UIViewController: CurrentNavController {
    var currentNavController: UINavigationController? {
        return navigationController
    }
}

