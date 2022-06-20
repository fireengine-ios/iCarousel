//
//  BaseViewController.swift
//  Depo
//
//  Created by Oleg on 13.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseViewController: ViewController {
    var keyboardHeight: CGFloat = 0
    var needToShowTabBar: Bool = false
    var floatingButtonsArray = [FloatingButtonsType]()
    var parentUUID: String = ""
    var segmentImage: SegmentedImage?

    var customTabBarController: TabBarViewController? {
        var parent = self.parent
        while parent != nil {
            if let tabBarController = parent as? TabBarViewController {
                return tabBarController
            }
            parent = parent?.parent
        }

        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customTabBarController?.setBottomBarsHidden(!needToShowTabBar)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getMainYForView(view: UIView) -> CGFloat {
        if (view.superview == self.view) {
            return view.frame.origin.y
        } else {
            if (view.superview != nil) {
                return view.frame.origin.y + getMainYForView(view: view.superview!)
            } else {
                return 0
            }
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
    }
    
    @objc func hideKeyboard() {
        keyboardHeight = 0
    }

    func searchActiveTextField(view: UIView) -> UITextField? {
        if let textField = view as? UITextField {
            if textField.isFirstResponder {
                return textField
            }
        }
        for subView in view.subviews {
            let textField = searchActiveTextField(view: subView)
            if textField != nil {
                return textField
            }
        }
        return nil
    }

    func showTabBarIfNeeded() {
        customTabBarController?.setBottomBarsHidden(isNeedToShowTabBar())
    }

    func isNeedToShowTabBar() -> Bool {
        return needToShowTabBar
    }

    // MARK: - Header Actions

    func setDefaultNavigationHeaderActions() {
        headerContainingViewController?.setHeaderLeftItems([
            NavigationHeaderButton(type: .settings, target: self, action: #selector(showSettings))
        ])
        headerContainingViewController?.setHeaderRightItems([
            NavigationHeaderButton(type: .search, target: self, action: #selector(showSearch)),
            NavigationHeaderButton(type: .plus, target: self, action: #selector(showPlusButtonMenu))
        ])
    }

    @objc private func showSettings() {
        let router = RouterVC()
        let controller: UIViewController?

        if Device.isIpad {
            controller = router.settingsIpad
        } else {
            controller = router.settings
        }

        if let controller = controller {
            router.pushViewController(viewController: controller)
        }
    }

    @objc private func showSearch() {
        let router = RouterVC()
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }

    @objc private func showPlusButtonMenu() {
        let menuItems = floatingButtonsArray.map { buttonType in
            AlertFilesAction(title: buttonType.title, icon: buttonType.image) { [weak self] in
                self?.customTabBarController?.handleAction(buttonType.action)
            }
        }

        let menu = AlertFilesActionsViewController()
        menu.configure(with: menuItems)
        menu.presentAsDrawer()
    }
}


// MARK: - UIViewControllerTransitioningDelegate

extension BaseViewController: UIViewControllerTransitioningDelegate {
    private func pushPopAnimatorForPresentation(presenting: Bool) -> UIViewControllerAnimatedTransitioning? {
        let animator = PushPopAnimator()
        animator.presenting = presenting
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return pushPopAnimatorForPresentation(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return pushPopAnimatorForPresentation(presenting: false)
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseViewController: UINavigationControllerDelegate  {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return pushPopAnimatorForPresentation(presenting: operation == .push)
    }
}
