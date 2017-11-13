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
    }
    
    func backButtonForNavigationItem(title: String) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: title,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
    }
    
    func setNavigationTitle(title: String) {
        navigationItem.title = title
        navBar?.titleTextAttributes = [NSAttributedStringKey.font: UIFont.TurkcellSaturaDemFont(size: 19), NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func hidenNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navBar?.isTranslucent = true
        defaultNavBarStyle()
    }

    func visibleNavigationBarStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navBar?.isTranslucent = true
    }
    
    func homePageNavigationBarStyle() {
        
        rootNavController(vizible: false)
        visibleNavigationBarStyle()
        defaultNavBarStyle()
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
        defaultNavBarStyle()
    }
 
    func navigationBarWithGradientStyle() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        defaultNavBarStyle()
        navBar?.backgroundColor = UIColor.white
        
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
    
    func customNavigationBarPushToBack() {
        if let view = customNavBarView {
            navBar?.sendSubview(toBack: view)
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
            navBar?.subviews[0].viewWithTag(tagTitleView)?.removeFromSuperview()
            let delta: CGFloat = 50.0
            let weihth = Device.winSize.width - delta*2.0
            let mainTitleLabel = UILabel(frame: CGRect(x: delta, y: 20, width: weihth, height: 40))
            mainTitleLabel.backgroundColor = UIColor.clear
            mainTitleLabel.numberOfLines = 2
            mainTitleLabel.textAlignment = .center
            mainTitleLabel.textColor = UIColor.white
            
            let attributtedText = NSMutableAttributedString(string: title + "\n" + subTitle)
            attributtedText.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaDemFont(size: 19.0)], range: NSMakeRange(0, (title as NSString).length))
            attributtedText.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaMedFont(size: 12.0)], range: NSMakeRange((title as NSString).length + 1, (subTitle as NSString).length))
            mainTitleLabel.attributedText = attributtedText
            mainTitleLabel.tag = tagTitleView
            navBar?.subviews[0].addSubview(mainTitleLabel)
        } else {
            self.navBar?.subviews[0].viewWithTag(tagTitleView)?.removeFromSuperview()
            self.navigationItem.title = title
        }
    }
    
}
