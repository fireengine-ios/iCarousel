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
    
    private var customNavBarView: CustomNavBarView? {
        
        if let view = CustomNavBarView.getFromNib(),
            let _ = navBar?.frame {
            
            let frame = CGRect(x: 0,
                               y: -20,
                               width: (Device.winSize.width),
                               height: view.frame.height)
            view.frame = frame
            view.tag = tagHomeView
            view.layoutIfNeeded()
            return view
        }
        return nil
    }
    
    var statusBarColor: UIColor? {
        get {
            return UIApplication.shared.statusBarView?.backgroundColor
        }
        set {
            UIApplication.shared.statusBarView?.backgroundColor = newValue
        }
    }
    
    func defaultNavBarStyle(backgroundImg: UIImage = UIImage()) {
        visibleNavigationBarStyle()
        navBar?.setBackgroundImage(backgroundImg, for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.backgroundColor = .clear
        navBar?.barTintColor = .clear
        navBar?.tintColor = .white
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        if let view = navBar?.viewWithTag(tagHomeView) {
            view.removeFromSuperview()
        }
        
        statusBarColor = .clear
    }
    
    func backButtonForNavigationItem(title: String) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        navigationItem.backBarButtonItem?.tintColor = .white
    }
    
    func setNavigationTitle(title: String) {
        navigationItem.titleView = nil
        navigationItem.title = title
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont.TurkcellSaturaDemFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func setNavigationRightBarButton(title: String, target: AnyObject, action: Selector) {
        guard target.responds(to: action) else {
            assertionFailure()
            return
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title,
                                                            style: .done,
                                                            target: target,
                                                            action: action)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                                   .foregroundColor: UIColor.white], for: .normal)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func setNavigationBackgroundColor(color: UIColor) {
        navBar?.backgroundColor = color
    }
    
    func hidenNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navBar?.tintColor = .white
        navBar?.barTintColor = .clear
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        if let view = navBar?.viewWithTag(tagHomeView) {
            view.removeFromSuperview()
        }
        statusBarColor = .clear
        
        navBar?.isTranslucent = true
    }

    func visibleNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navBar?.isTranslucent = false
    }
    
    func homePageNavigationBarStyle() {
        defaultNavBarStyle()
        setTitle(withString: "")
        navBar?.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            let image = UIImage(named: "NavigationBarBackground")
            navBar?.setBackgroundImage(image, for: .default)
        }
        
        if let view = customNavBarView {
            view.hideLogo = false
            navBar?.insertSubview(view, at: 0)
            navBar?.addSubview(view)
        }
    }
    
    func blackNavigationBarStyle() {
        defaultNavBarStyle()
        
        if #available(iOS 11.0, *) {
            let image = UIImage(named: "NavigatonBarBlackBacground")
            navBar?.setBackgroundImage(image, for: .default)
        }
        
        navBar?.barTintColor = .black
        navBar?.backgroundColor = .black
        statusBarColor = .black
        navBar?.isTranslucent = true
    }
    
    func navigationBarWithGradientStyleWithoutInsets() {
        defaultNavBarStyle()
        
        setTitle(withString: "")
        navBar?.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            let image = UIImage(named: "NavigationBarBackground")
            navBar?.setBackgroundImage(image, for: .default)
        }
        
        if let view = customNavBarView {
            view.hideLogo = true
            navBar?.insertSubview(view, at: 0)
            navBar?.addSubview(view)
        }
    }
 
    func navigationBarWithGradientStyle() {
        defaultNavBarStyle()
        
        navBar?.backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            let image = UIImage(named: "NavigationBarBackground")
            navBar?.setBackgroundImage(image, for: .default)
        }
        
        if let view = customNavBarView {
            view.hideLogo = true
            view.frame = CGRect(x: 0,
                                y: 0,
                                width: (Device.winSize.width),
                                height: view.frame.height)
            navBar?.subviews[0].addSubview(view)
        }
    }
    
    //MARK : ToolBar
    
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
        
        if #available(iOS 11.0, *) {
            // do nothing
        } else {
            // trick for resize
            customTitleView.translatesAutoresizingMaskIntoConstraints = false
            customTitleView.layoutIfNeeded()
            customTitleView.sizeToFit()
            customTitleView.translatesAutoresizingMaskIntoConstraints = true
        }
        
        navigationItem.titleView = customTitleView
        
        navigationItem.titleView?.isUserInteractionEnabled = true
    }

    
}
