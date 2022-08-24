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
            let gestureRecognizer = TapGestureRecognizerWithClosure(closure: { [weak self] in
                DispatchQueue.main.async {
                    cancel()
                    self?.hideSpinnerIncludeNavigationBar()
                    self?.postAccessibilityScreenChanged(view: self!.view)
                }
            })
            hud.backgroundView.addGestureRecognizer(gestureRecognizer)
            self.postAccessibilityScreenChanged(view: hud)
        }
    }
    
    func showSpinner() {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.postAccessibilityScreenChanged(view: hud)
        }
    }
    
    func showSpinnerOnView(_ view: UIView) {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            self.postAccessibilityScreenChanged(view: hud)
        }
    }
    
    func showSpinnerIncludeNavigationBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            window.addSubview(hud)
            self.postAccessibilityScreenChanged(view: hud)
        }
    }
    
    func hideSpinnerIncludeNavigationBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            MBProgressHUD.hideAllHUDs(for: window, animated: true)
            self.postAccessibilityScreenChanged(view: self.view)
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.postAccessibilityScreenChanged(view: self.view)
        }
    }
    
    func hideSpinerForView(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
            self.postAccessibilityScreenChanged(view: self.view)
        }
    }

    private func postAccessibilityScreenChanged(view: UIView) {
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }
}

extension UIViewController {
    func createAlert(title: String?, message: String, firstTitle: String, secondTitle: String? = nil, cancelOnly: Bool? = false,
                     handler: @escaping (UIAlertAction.Style) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: firstTitle, style: .default, handler: { _ in
            handler(.cancel)
        }))
        
        if cancelOnly == false {
            alert.addAction(UIAlertAction(title: secondTitle, style: .default, handler: { _ in
                handler(.default)
            }))
        }
        return alert
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
