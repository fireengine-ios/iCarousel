//
//  ViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 04/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    
    var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    // MARK: - Helpers
    
    func setStatusBarHiddenForLandscapeIfNeed(_ hidden: Bool) {
        if !Device.isIpad, UIDevice.current.orientation.isContained(in: [.landscapeLeft, .landscapeRight]) {
            statusBarHidden = true
        } else {
            statusBarHidden = hidden
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.checkModalPresentationStyle()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension UIViewController {
    func checkModalPresentationStyle() {
        guard #available(iOS 13.0, *) else {
            return
        }
        
        #if swift(>=5.0)
            if modalPresentationStyle.isContained(in: [.automatic, .pageSheet]) {
                modalPresentationStyle = .fullScreen
            }
        #else //TODO: as soon as jenkins is updated to xcode 11 - remove this if
            if modalPresentationStyle.isContained(in: [ .pageSheet]) {
                modalPresentationStyle = .fullScreen
            }
        #endif
        
    }
}
