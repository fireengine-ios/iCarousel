//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by - on 7/8/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit

enum NavigationBarStyles {
    case byDefault
    case white
    case transparent
    case visible
    case hidden
    case black
    
    var titleAtributes: [NSAttributedStringKey : Any]? {
        switch self {
        case .byDefault, .white, .visible:
            return [
                .font: UIFont.GTAmericaStandardMediumFont(size: 17),
                .foregroundColor: ColorConstants.confirmationPopupTitle
            ]
        case .black, .transparent, .hidden:
            return [
                .font: UIFont.GTAmericaStandardMediumFont(size: 17),
                .foregroundColor: UIColor.white
            ]
        }
    }
    
    var textTintColor: UIColor  {
        switch self {
        case .byDefault, .white, .visible:
            return ColorConstants.confirmationPopupTitle
        case .black, .transparent, .hidden:
            return UIColor.white
        }
    }
    
    var backButtonTitleAttributes: [NSAttributedStringKey : Any]? {
        switch self {
        case .byDefault, .white, .visible:
            return [
                .font: UIFont.GTAmericaStandardRegularFont(size: 19),
                .foregroundColor: ColorConstants.confirmationPopupTitle
            ]
        case .black, .transparent, .hidden:
            return [
                .font: UIFont.GTAmericaStandardMediumFont(size: 19),
                .foregroundColor: UIColor.white
            ]
        }
    }
    
    var largeTitleAttributes: [NSAttributedStringKey : Any]? {
        switch self {
        case .byDefault, .white, .visible:
            return [
                .font: UIFont.GTAmericaStandardRegularFont(size: 24),
                .foregroundColor: ColorConstants.confirmationPopupTitle
            ]
        case .black, .transparent, .hidden:
            return [
                .font: UIFont.GTAmericaStandardMediumFont(size: 24),
                .foregroundColor: ColorConstants.confirmationPopupTitle
            ]
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .byDefault, .white, .visible:
            return ColorConstants.topBarColor
        case .transparent, .hidden:
            return .clear
        case .black:
            return .black
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .byDefault, .white, .visible, .transparent, .hidden, .black:
            return .clear
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .byDefault, .white, .visible, .transparent, .hidden, .black:
            return .clear
        }
    }
    
    var statusBarColor: UIColor {
        switch self {
        case .byDefault, .white, .visible, .transparent, .hidden, .black:
            return .clear
        }
    }
    
    var isTranslucent: Bool {
        switch self {
        case .byDefault, .white, .visible, .black:
            return false
        case .transparent, .hidden:
            return true
        }
    }
    
    var isHidden: Bool {
        switch self {
        case .transparent, .byDefault, .white, .visible, .black:
            return false
        case .hidden:
            return true
        }
    }
    
    var backgroundImage: UIImage? {
        switch self {
        case .byDefault, .white, .visible, .hidden:
            return nil
        case .transparent:
            return UIImage()
        case .black:
            return UIImage(named: "NavigatonBarBlackBacground")
        }
    }
    
    var backButon: UIBarButtonItem {
        let defaultBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        defaultBackButton.tintColor = self.textTintColor
        defaultBackButton.setTitleTextAttributes(self.backButtonTitleAttributes, for: .normal)
        
        return defaultBackButton
    }
    
    func getBarButton(title: String, target: Any?, acion: Selector?) -> UIBarButtonItem {
        let defaultBackButton = UIBarButtonItem(title: title, style: .plain, target: target, action: acion)
        defaultBackButton.tintColor = self.textTintColor
        defaultBackButton.setTitleTextAttributes(self.backButtonTitleAttributes, for: .normal)
        return defaultBackButton
    }
    
}

enum CustomBackButtonType {
    case regular
    case cross
    
    var image: UIImage? {
        switch self {
        case .regular:
            return UIImage(named: "blackBackButton")
        case .cross:
            return UIImage(named: "close")
        }
    }
}

//MARK: - NavBar Styles

extension UIViewController {
    
    func setNavigationBarStyle(_ style: NavigationBarStyles) {
        navigationController?.setNavigationBarHidden(style.isHidden, animated: false)
        navBar?.isTranslucent = style.isTranslucent
        
        guard !style.isHidden else {
            return
        }
        
        if !isModal() || navigationController != nil {
            //TODO: change so we dont always setup, but check first if this button exiist and then just channge properties
            navBar?.topItem?.backBarButtonItem = style.backButon
        }
        
        navBar?.titleTextAttributes = style.titleAtributes
        navBar?.barTintColor = style.barTintColor
        navBar?.tintColor = style.tintColor
        navBar?.backgroundColor = style.backgroundColor
        navBar?.setBackgroundImage(style.backgroundImage, for: .default)
        navBar?.shadowImage = UIImage()
        
        statusBarColor = style.statusBarColor
    }
}

//MARK: - Main Properties and buttotos

extension UIViewController {
    
    func rootNavController(vizible: Bool) {
        let rootNavController = RouterVC().navigationController
        rootNavController?.setNavigationBarHidden(!vizible, animated: false)
    }
    
    var navBar: UINavigationBar? {
        return navigationController?.navigationBar
    }
    
    var statusBarColor: UIColor? {
        get {
            return UIApplication.shared.statusBarView?.backgroundColor
        }
        set {
            UIApplication.shared.statusBarView?.backgroundColor = newValue
        }
    }
    
    func setNavigationBackgroundColor(color: UIColor) {
        navBar?.backgroundColor = color
    }
    
    func changeSearchBar(controller: UISearchController?) {
        if let controller = controller, navigationItem.searchController == nil {
            navigationItem.searchController = controller
        } else if controller == nil {
            navigationItem.searchController = controller
        }
    }
}

//MARK: - Modal

extension UIViewController {
    func isModal() -> Bool {
        if presentedViewController != nil || navigationController?.presentingViewController?.presentedViewController != nil || presentingViewController != nil {
            return true
        } else {
            return false
        }
    }
    
    @objc private func popModal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func popNavigation() {
//        let navController = navigationController ?? self
//        navController.
//        var navigationController: UINavigationController? {
//            if let navController = rootViewController as? UINavigationController {
//                return navController
//            } else if let tabBarController = tabBarController {
//                if let navVC = tabBarController.presentedViewController as? NavigationController {
//                    return navVC
//                } else {
//                    return tabBarController.activeNavigationController
//                }
//            } else {
//                return nil
//            }
//        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func backAction() {
        isModal() ? popModal() : popNavigation()
    }
}

//MARK: - Title Related
extension UIViewController {

    var tagHomeView: Int {
        return 45634
    }
    
    var tagTitleView: Int {
        return 787878
    }
    
    func setTitle(withString title: String, andSubTitle subTitle: String? = nil) {

        navBar?.topItem?.backBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle, style: .plain, target: nil, action: nil)
        navBar?.topItem?.backBarButtonItem?.tintColor = ColorConstants.confirmationPopupTitle

        if let subTitle = subTitle {
            navigationItem.title = nil
            navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()

            let customTitleView = TitleView.initFromXib()
            customTitleView.tag = tagTitleView
            customTitleView.setTitle(title)
            customTitleView.setSubTitle(subTitle)

            navigationItem.titleView = customTitleView
        } else {
            navigationItem.titleView = nil
            navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()
            setNavigationTitle(title: title, style: .byDefault)
        }
    }
    
    //MARK: with style
    func changeLargeTitle(prefersLargeTitles: Bool, barStyle: NavigationBarStyles) {
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        if prefersLargeTitles {
            navigationController?.navigationBar.largeTitleTextAttributes = barStyle.largeTitleAttributes
        }
    }
    
    func setNavigationTitle(title: String, style: NavigationBarStyles) {
        self.title = title
        navBar?.titleTextAttributes = style.titleAtributes
    }
    
}

//MARK: Buttons

extension UIViewController {
    
    func setupCustomButtonAsNavigationBackButton(style: NavigationBarStyles, asLeftButton: Bool, title: String, target: Any?, image: UIImage?, action: Selector?) {

        navigationItem.hidesBackButton = true
        
        let buttonImage: UIImage? = image == nil ? CustomBackButtonType.regular.image : image
        
        let barButton = style.getBarButton(title: title, target: target, acion: action)
        barButton.image = buttonImage
        
        if action == nil {
            barButton.action = #selector(backAction)
        }
        
        if asLeftButton {
            navigationItem.leftBarButtonItem = barButton
        } else {
            navigationItem.rightBarButtonItem = barButton
        }
    }
    
    func setBackButtonForNavigationItem(style: NavigationBarStyles, title: String, target: Any?, action: Selector?) {
        navigationItem.backBarButtonItem = style.getBarButton(title: title, target: target, acion: action)
    }
    
    func setBackButtonForNavigationItem(button: UIBarButtonItem, style: NavigationBarStyles) {
        navigationItem.backBarButtonItem = button
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes(style.backButtonTitleAttributes, for: .normal)
        
        navigationItem.backBarButtonItem?.tintColor = style.textTintColor
    }
    
    func setNavigationLeftBarButton(style: NavigationBarStyles, title: String, target: Any?, image: UIImage?, action: Selector?) {
        let leftButton = style.getBarButton(title: title, target: target, acion: action)
        leftButton.image = image
        
        navigationItem.leftBarButtonItem = leftButton
    }
    
    func setNavigationRightBarButton(style: NavigationBarStyles, title: String, image: UIImage? = nil, target: AnyObject, action: Selector) {
        guard target.responds(to: action) else {
            assertionFailure()
            return
        }
        
        let rightBarButtonItem = style.getBarButton(title: title, target: target, acion: action)
        rightBarButtonItem.image = image
        rightBarButtonItem.style = .done

        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
