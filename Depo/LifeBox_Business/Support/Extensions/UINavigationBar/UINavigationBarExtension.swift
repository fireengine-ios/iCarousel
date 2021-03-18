//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum NavigationBarStyles {
    case byDefault
    case white
    case transparetn
    case visible
    case hidden
    case black
}

extension UIViewController {
    
    func rootNavController(vizible: Bool) {
        let rootNavController = RouterVC().navigationController
        rootNavController?.setNavigationBarHidden(!vizible, animated: false)
    }
    
//MARK: Properties
    
    var statusBarColor: UIColor? {
        get {
            return UIApplication.shared.statusBarView?.backgroundColor
        }
        set {
            UIApplication.shared.statusBarView?.backgroundColor = newValue
        }
    }
    
//MARK: Properties (private)
    
    private var backButtonTitleAttributes: [NSAttributedStringKey : Any]? {
        return [
            .font: UIFont.GTAmericaStandardRegularFont(size: 19),
            .foregroundColor: ColorConstants.confirmationPopupTitle
        ]
    }
    
    private var titleAttributes: [NSAttributedStringKey : Any]? {
        return [
            .font: UIFont.GTAmericaStandardMediumFont(size: 17),
            .foregroundColor: ColorConstants.confirmationPopupTitle
        ]
    }
    
    private var largeTitleAttributes: [NSAttributedStringKey : Any]? {
        return [
            .font: UIFont.GTAmericaStandardMediumFont(size: 24),
            .foregroundColor: ColorConstants.confirmationPopupTitle
//=======
//            .foregroundColor: ColorConstants.multifileCellRenameFieldNameColor
//>>>>>>> develop_v2
        ]
    }
    
//MARK: NavBar customization
    
    func backButtonForNavigationItem(title: String) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes(backButtonTitleAttributes, for: .normal)
        
        navigationItem.backBarButtonItem?.tintColor = ColorConstants.confirmationPopupTitle
    }
    
    func setNavigationTitle(title: String, isLargeTitle: Bool) {
        navigationItem.title = title
        navBar?.titleTextAttributes = titleAttributes

        changeLargeTitle(prefersLargeTitles: isLargeTitle)
    }
    
    func setNavigationRightBarButton(title: String, target: AnyObject, action: Selector) {
        guard target.responds(to: action) else {
            assertionFailure()
            return
        }
        
        let rightBarButtonItem = UIBarButtonItem(title: title,
                                                 font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                 tintColor: .white,
                                                 accessibilityLabel: nil,
                                                 style: .done,
                                                 target: target,
                                                 selector: action)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setNavigationBackgroundColor(color: UIColor) {
        navBar?.backgroundColor = color
    }
    
    func changeSearchBar(controller: UISearchController?) {
        navigationItem.searchController = controller
    }
    
    func changeLargeTitle(prefersLargeTitles: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        if prefersLargeTitles {
            navigationController?.navigationBar.largeTitleTextAttributes = largeTitleAttributes
        }
    }
    
}

//MARK: - Subtitle
extension UIViewController {
    
    var navBar: UINavigationBar? {
        return navigationController?.navigationBar
    }
    
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
            navigationItem.title = title
        }
    }
}


//MARK: - Styles

extension UIViewController {
    
//MARK: NavBar presets
    
    func setNavigationBarStyle(_ style: NavigationBarStyles) {
        switch style {
        case .byDefault:
            defaultNavBarStyle()
        case .white:
            whiteNavBarStyle()
        case .transparetn:
            transparentNavBarStyle()
        case .visible:
            visibleNavigationBarStyle()
        case .hidden:
            hiddenNavigationBarStyle()
        case .black:
            blackNavigationBarStyle()
        }
    }
    
    func defaultNavBarStyle() {
        navBar?.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navBar?.topItem?.backBarButtonItem?.tintColor = ColorConstants.confirmationPopupTitle
//=======
//        navBar?.titleTextAttributes = [.foregroundColor : titleTextColor]
//        navBar?.topItem?.backBarButtonItem?.tintColor = .black
//>>>>>>> develop_v2

        navBar?.titleTextAttributes = [.foregroundColor : ColorConstants.confirmationPopupTitle]
        
        statusBarColor = .clear
    }

    func whiteNavBarStyle() {
        
        visibleNavigationBarStyle()

        defaultNavBarStyle()
        
//        changeLargeTitle(prefersLargeTitles: isLargeTitle)
        
        navigationItem.hidesSearchBarWhenScrolling = true
        
        navBar?.barTintColor = ColorConstants.topBarColor
        navBar?.shadowImage = UIImage()
        navBar?.backgroundColor = .clear
        navBar?.tintColor = .clear
    }
    
    func transparentNavBarStyle() {
        navBar?.isTranslucent = true

        navBar?.barTintColor = .clear
        navBar?.shadowImage = UIImage()
        navBar?.backgroundColor = .clear
        navBar?.tintColor = .clear
    }
    
    func blackNavigationBarStyle() {
        defaultNavBarStyle()
        
        let image = UIImage(named: "NavigatonBarBlackBacground")
        navBar?.setBackgroundImage(image, for: .default)

        statusBarColor = .black

        navBar?.barTintColor = .black
        navBar?.backgroundColor = .black
    }
    
    //MARK: NavBar visibility states

    func hiddenNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationController?.view.backgroundColor = .clear

        defaultNavBarStyle()//(isHidden: true)
        
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        
        navBar?.tintColor = .white
        navBar?.barTintColor = .clear
        navBar?.titleTextAttributes = [.foregroundColor : UIColor.white]

        statusBarColor = .clear
    }

    func visibleNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navBar?.isTranslucent = false
    }
}
