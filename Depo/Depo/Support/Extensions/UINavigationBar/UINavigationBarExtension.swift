//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func rootNavController(vizible: Bool)  {
        let rootNavController = RouterVC().navigationController
        rootNavController?.setNavigationBarHidden(!vizible, animated: false)
    }
    
    private var navBar: UINavigationBar? {
       return navigationController?.navigationBar
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
    
    private var tagHomeView: Int {
        return 45634
    }
    
    private var tagTitleView: Int {
        return 787878
    }
    
    func defaultNavBarStyle(backgroundImg: UIImage = UIImage()) {
        navBar?.setBackgroundImage(backgroundImg,for: UIBarMetrics.default)
        navBar?.shadowImage = UIImage()
        navBar?.backgroundColor = UIColor.clear
        navBar?.tintColor = UIColor.white
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white];
        
        if let view = navBar?.viewWithTag(tagHomeView)  {
            view.removeFromSuperview()
        }
        
        setStatusBarBackgroundColor(color: UIColor.clear)
    }
    
    func backButtonForNavigationItem(title: String) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    func setNavigationTitle(title: String) {
        self.navigationItem.titleView = nil
        navigationItem.title = title
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont.TurkcellSaturaDemFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        UIApplication.shared.statusBarView?.backgroundColor = color
    }
    
    func setNavigationBackgroundColor(color: UIColor) {
        navBar?.backgroundColor = color
    }
    
    func hidenNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white];

        if let view = navBar?.viewWithTag(tagHomeView)  {
            view.removeFromSuperview()
        }
        setStatusBarBackgroundColor(color: UIColor.clear)
        
        navBar?.isTranslucent = true
    }

    func visibleNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navBar?.isTranslucent = false
    }
    
    func homePageNavigationBarStyle() {
        defaultNavBarStyle()
        visibleNavigationBarStyle()
        self.setTitle(withString: "")
        navBar?.backgroundColor = UIColor.white
        
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
        visibleNavigationBarStyle()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        defaultNavBarStyle()
        
        if #available(iOS 11.0, *) {
            let image = UIImage(named: "NavigatonBarBlackBacground")
            navBar?.setBackgroundImage(image, for: .default)
        }
        
        navBar?.backgroundColor = UIColor.black
        setStatusBarBackgroundColor(color: UIColor.black)
        navBar?.isTranslucent = true
    }
    
    func navigationBarWithGradientStyleWithoutInsets() {
        visibleNavigationBarStyle()
        defaultNavBarStyle()
        self.setTitle(withString: "")
        navBar?.backgroundColor = UIColor.white
        
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
        visibleNavigationBarStyle()
        navigationController?.setNavigationBarHidden(false, animated: false)
        defaultNavBarStyle()
        navBar?.backgroundColor = UIColor.clear
        
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
    
    func setTitle(withString title: String, andSubTitle subTitle: String! = nil) {
        
        navBar?.topItem?.backBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle, style: .plain, target: nil, action: nil)
        
        if let _ = subTitle {
            navigationItem.title = nil
            navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()

            let customTitleView = TitleView.initFromXib()
            customTitleView.tag = tagTitleView
            customTitleView.setTitle(title)
            customTitleView.setSubTitle(subTitle)
            
            if #available(iOS 11.0, *) {
                // do nothing
            } else {
                // trick for resize
                customTitleView.translatesAutoresizingMaskIntoConstraints = false
                customTitleView.layoutIfNeeded()
                customTitleView.sizeToFit()
                customTitleView.translatesAutoresizingMaskIntoConstraints = true
            }

            self.navigationItem.titleView = customTitleView
        } else {
            self.navigationItem.titleView = nil
            self.navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()
            self.navigationItem.title = title
        }
    }
    
    func setTouchableTitle(title: String) {
        navBar?.viewWithTag(tagTitleView)?.removeFromSuperview()
        let titleLabel = UILabel()        
        titleLabel.tag = tagTitleView
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 19.0)
        titleLabel.text = title
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        navigationItem.titleView?.isUserInteractionEnabled = true
    }

    
}
