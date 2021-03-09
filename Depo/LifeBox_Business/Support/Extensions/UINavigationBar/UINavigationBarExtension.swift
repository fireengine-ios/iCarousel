//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

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
    
    private var navBarHeight: CGFloat {
        var height: CGFloat = UIApplication.shared.statusBarFrame.height
        
        height += navBar?.frame.height ?? 0

        return height
    }
    
    private var backButtonTitleAttributes: [NSAttributedStringKey : Any]? {
        return [
            .font: UIFont.GTAmericaStandardRegularFont(size: 19),
            .foregroundColor: ColorConstants.confirmationPopupTitle
        ]
    }
    
    private var titleAttributes: [NSAttributedStringKey : Any]? {
        return [
            .font: UIFont.GTAmericaStandardMediumFont(size: 19),
            .foregroundColor: UIColor.green//ColorConstants.confirmationPopupTitle
        ]
    }
    
//MARK: NavBar customization
    
    func backButtonForNavigationItem(title: String) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes(backButtonTitleAttributes, for: .normal)
        
        navigationItem.backBarButtonItem?.tintColor = ColorConstants.confirmationPopupTitle
    }
    
    func setNavigationTitle(title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
//        titleLabel.at
        navigationItem.titleView = titleLabel
//        navigationItem.title = title
        navBar?.titleTextAttributes = titleAttributes
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
    
    //MARK: NavBar visibility states

    func hidenNavigationBarStyle() {
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
    
//MARK: NavBar presets
    
    func defaultNavBarStyle() {
        visibleNavigationBarStyle()
        
        navBar?.topItem?.backBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle, style: .plain, target: nil, action: nil)
        navBar?.topItem?.backBarButtonItem?.tintColor = ColorConstants.confirmationPopupTitle
        
        navBar?.barTintColor = ColorConstants.topBarColor
        
        navBar?.titleTextAttributes = [.foregroundColor : ColorConstants.confirmationPopupTitle]
        
        statusBarColor = .clear
    }

    func whiteNavBarStyle(backgroundImg: UIImage = UIImage(),
                          tintColor: UIColor = .black,
                          titleTextColor: UIColor = .black) {
        visibleNavigationBarStyle()

//        if let view = navBar?.viewWithTag(tagHomeView) as? CustomNavBarView {
////            view.hideLogo = true
//            view.isHidden = true
//
//        }

        navBar?.setBackgroundImage(backgroundImg, for: .default)
        navBar?.shadowImage = UIImage()

        navBar?.backgroundColor = .white
        navBar?.barTintColor = .white
        navBar?.tintColor = tintColor

        navBar?.titleTextAttributes = [.foregroundColor : titleTextColor]

        statusBarColor = .clear
    }

    func homePageNavigationBarStyle() {
        defaultNavBarStyle()
        setTitle(withString: "")
        
        defaultNavBarStyle()//(hideLogo: false)
    }
    
    func blackNavigationBarStyle() {
        defaultNavBarStyle()
        
        let image = UIImage(named: "NavigatonBarBlackBacground")
        navBar?.setBackgroundImage(image, for: .default)

        statusBarColor = .black

        navBar?.barTintColor = .black
        navBar?.backgroundColor = .black
    }
    
    func defaultNavBarStyleWithoutInsets() {
        defaultNavBarStyle()
        setTitle(withString: "")
    }
    
//MARK: ToolBar
    
    func barButtonItemsWithRitht(button: UIBarButtonItem) -> UIToolbar {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil,
                                   action: nil)
        
        toolBar.setItems([flex, button], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    func setTouchableTitle(title: String) {
        navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()
        
        let customTitleView = TitleView.initFromXib()
        customTitleView.tag = tagTitleView
        customTitleView.setTitle(title)
        
        navigationItem.titleView = customTitleView
        
        navigationItem.titleView?.isUserInteractionEnabled = true
    }
}
