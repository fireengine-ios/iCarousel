//
//  ViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 04/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NavigationBarStyling {
    var preferredNavigationBarStyle: NavigationBarStyle {
        return .default
    }

    var navigationBarHidden: Bool = false {
        didSet {
            if isTopViewController {
                updateNavigationBarVisibilityIfNeeded()
            }
        }
    }

    var statusBarHidden = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var statusBarStyle: UIStatusBarStyle = .default {
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

    var needCheckModalPresentationStyle = true

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarVisibilityIfNeeded(animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateNavigationBarVisibilityIfNeeded(animated: false)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.checkModalPresentationStyle()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    // MARK: - Helpers

    private var isTopViewController: Bool {
        return navigationController?.topViewController == self
    }
    
    func setStatusBarHiddenForLandscapeIfNeed(_ hidden: Bool) {
        if !Device.isIpad, UIDevice.current.orientation.isContained(in: [.landscapeLeft, .landscapeRight]) {
            statusBarHidden = true
        } else {
            statusBarHidden = hidden
        }
    }

    private func updateNavigationBarVisibilityIfNeeded(animated: Bool = true) {
        guard let navigationController = navigationController else {
            return
        }

        guard navigationBarHidden != navigationController.isNavigationBarHidden else {
            return
        }

        navigationController.setNavigationBarHidden(navigationBarHidden, animated: animated)
    }
    
}

extension UIViewController {
    func checkModalPresentationStyle() {
        guard #available(iOS 13.0, *) else {
            return
        }

        if (self as? ViewController)?.needCheckModalPresentationStyle == false {
            return
        }

        if modalPresentationStyle.isContained(in: [.automatic, .pageSheet]) {
            modalPresentationStyle = .fullScreen
        }
    }
}
