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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let topVC = UIApplication.topController()
        if let tabBarVC = topVC as? TabBarViewController {
            tabBarVC.statusBarStyle = preferredStatusBarStyle
            if let navVC = tabBarVC.activeNavigationController as? NavigationController {
                navVC.statusBarStyle = preferredStatusBarStyle
            }
        }
    }
    
    func setStatusBarHiddenForLandscapeIfNeed(_ hidden: Bool) {
        if !Device.isIpad, UIDevice.current.orientation.isContained(in: [.landscapeLeft, .landscapeRight]) {
            statusBarHidden = true
        } else {
            statusBarHidden = hidden
        }
    }
    
}
