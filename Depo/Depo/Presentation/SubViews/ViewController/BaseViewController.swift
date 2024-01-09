//
//  BaseViewController.swift
//  Depo
//
//  Created by Oleg on 13.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class NotificationHolder {
    var count = 0
    var popupStatus = true
    static let shared = NotificationHolder()
}

class BaseViewController: ViewController {
    var keyboardHeight: CGFloat = 0
    var needToShowTabBar: Bool = false
    var floatingButtonsArray = [FloatingButtonsType]()
    var parentUUID: String = ""
    var segmentImage: SegmentedImage?
    
    private var settingsNavButton = NavigationHeaderButton()
    private let service = NotificationService()

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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setProfilePhoto),
                                               name: .setProfilePhoto,
                                               object: nil)
    }
    
    @objc private func setProfilePhoto() {
        setDefaultNavigationHeaderActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customTabBarController?.setBottomBarsHidden(!needToShowTabBar)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        
        
        settingsNavButton.setnotificationCount(with: NotificationHolder.shared.count)
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
        settingsNavButton = NavigationHeaderButton(type: .settings, target: self, action: #selector(showSettings))
        headerContainingViewController?.setHeaderLeftItems([
            settingsNavButton
        ])
        headerContainingViewController?.setHeaderRightItems([
            NavigationHeaderButton(type: .search, target: self, action: #selector(showSearch)),
            NavigationHeaderButton(type: .plus, target: self, action: #selector(showPlusButtonMenu))
        ])
    }
    
    func setDefaultNavigationHeaderActionsWithoutPlusButton() {
        settingsNavButton = NavigationHeaderButton(type: .settings, target: self, action: #selector(showSettings))
        headerContainingViewController?.setHeaderLeftItems([
            settingsNavButton
        ])
        headerContainingViewController?.setHeaderRightItems([
            NavigationHeaderButton(type: .search, target: self, action: #selector(showSearch))
            
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

extension BaseViewController {
    func fetchNotificationPopup(completion: @escaping (_ response: NotificationServiceResponse) -> Void) {
        
        // To make sure it won't be called more than one
        guard NotificationHolder.shared.popupStatus else { return }
        NotificationHolder.shared.popupStatus.toggle()
        
        service.fetch(type: .popup,
            success: { response in
                guard let notification = response as? NotificationResponse else { return }
                DispatchQueue.main.async {
                    
                    let filtered = notification.list
                    
                    let popupP = filtered.sorted { one, two in
                        let dateOne = Date(timeIntervalSince1970: TimeInterval(one.createdDate ?? 0) / 1000)
                        let dateTwo = Date(timeIntervalSince1970: TimeInterval(two.createdDate ?? 0) / 1000)
                        
                        return dateOne > dateTwo
                    }
                    
                    let popup = popupP.sorted { one, two in
                        one.priority ?? 0 < two.priority ?? 0
                    }
                    
                    if let content = popup.first {
                        completion(content)
                    }
                }
            }, fail: { errorResponse in
        })
    }
    
    func fetchNotificationCount() {
        service.fetch(type: .inapp,
            success: { [weak self] response in
                guard let notification = response as? NotificationResponse else { return }
                DispatchQueue.main.async {
                    let count = notification.list.map({$0.status == "UNREAD"}).filter({$0}).count
                    NotificationHolder.shared.count = count
                    self?.settingsNavButton.setnotificationCount(with: count)
                }
            }, fail: { [weak self] errorResponse in
                NotificationHolder.shared.count = 0
                self?.settingsNavButton.setnotificationCount(with: 0)
        })
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseViewController: UINavigationControllerDelegate  {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return pushPopAnimatorForPresentation(presenting: operation == .push)
    }
}
