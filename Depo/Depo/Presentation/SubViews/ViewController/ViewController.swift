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
        return .gradient
    }
    // MARK: - Helpers
    
    func setStatusBarHiddenForLandscapeIfNeed(_ hidden: Bool) {
        if !Device.isIpad, UIDevice.current.orientation.isContained(in: [.landscapeLeft, .landscapeRight]) {
            statusBarHidden = true
        } else {
            statusBarHidden = hidden
        }
    }    
}
