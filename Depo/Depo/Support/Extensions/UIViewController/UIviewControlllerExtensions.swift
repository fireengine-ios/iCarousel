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

// MARK: - WAITING

protocol Waiting {
    
    func showSpinner()
    
    func showSpinnerOnView(_ view: UIView)
    
    func showSpinnerIncludeNavigationBar()
    
    func showSpinerWithCancelClosure(_ cancel: @escaping VoidHandler)
    func showFullscreenHUD(with text: String?, and cancelHandler: @escaping VoidHandler)
    
    func hideSpinnerIncludeNavigationBar()
    
    func hideSpinner()
    
    func hideSpinerForView(_ view: UIView)
}

extension UIViewController: Waiting {
    
    func showFullscreenHUD(with text: String?, and cancelHandler: @escaping VoidHandler) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.mode = MBProgressHUDMode.indeterminate
            hud.label.text = text
            hud.backgroundView.color = UIColor.lightGray.withAlphaComponent(0.88)
            let gestureRecognizer = TapGestureRecognizerWithClosure(closure: { [weak self] in
                DispatchQueue.main.async {
                    cancelHandler()
                    self?.hideSpinnerIncludeNavigationBar()
                }
            })
            hud.backgroundView.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func showSpinerWithCancelClosure(_ cancel: @escaping VoidHandler) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.backgroundView.color = ColorConstants.whiteColor.withAlphaComponent(0.88)
            let oldColor = self.statusBarColor
            self.statusBarColor = .clear
            let gestureRecognizer = TapGestureRecognizerWithClosure(closure: { [weak self] in
                DispatchQueue.main.async {
                    cancel()
                    self?.hideSpinnerIncludeNavigationBar()
                    self?.statusBarColor = oldColor
                }
            })
            hud.backgroundView.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func showSpinner() {
        DispatchQueue.toMain {
            _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func showSpinnerOnView(_ view: UIView) {
        DispatchQueue.main.async {
            _ = MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    func showSpinnerIncludeNavigationBar() {
        DispatchQueue.toMain {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            window.addSubview(hud)
        }
    }
    
    func hideSpinnerIncludeNavigationBar() {
        DispatchQueue.toMain {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            MBProgressHUD.hideAllHUDs(for: window, animated: true)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
    }
    
    func hideSpinerForView(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}


// MARK: - CustomNavController

protocol CurrentNavController {
    var currentNavController: UINavigationController? { get }
}

extension UIViewController: CurrentNavController {
    var currentNavController: UINavigationController? {
        return navigationController
    }
}
