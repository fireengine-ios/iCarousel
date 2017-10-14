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
        if let view = customNavBarView {
            view.hideLogo = false
            navBar?.insertSubview(view, at: 0)
        }
    }
    
    func blackNavigationBarStyle() {
        defaultNavBarStyle()
    }
 
    func navigationBarWithGradientStyle() {
        defaultNavBarStyle()
        navBar?.backgroundColor = UIColor.white
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
    
    func setNavigationTitle(title:String, subtitle: String) -> UIView {
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:-5, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = frame.integral
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            titleLabel.frame = frame.integral
        }
        
        return  titleView
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
        self.navBar?.topItem?.backBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle, style: .plain, target: nil, action: nil)
        if let _ = subTitle {
            self.navigationItem.title = nil
            self.navBar?.subviews[0].viewWithTag(787878)?.removeFromSuperview()
            let mainTitleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: Device.winSize.width, height: 40))
            mainTitleLabel.backgroundColor = UIColor.clear
            mainTitleLabel.numberOfLines = 2
            mainTitleLabel.textAlignment = .center
            mainTitleLabel.textColor = UIColor.white
            let attributtedText = NSMutableAttributedString(string: title + "\n" + subTitle)
            attributtedText.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaDemFont(size: 19.0)], range: NSMakeRange(0, (title as NSString).length))
            attributtedText.addAttributes([NSAttributedStringKey.font : UIFont.TurkcellSaturaMedFont(size: 12.0)], range: NSMakeRange((title as NSString).length + 1, (subTitle as NSString).length))
            mainTitleLabel.attributedText = attributtedText
//            mainTitleLabel.isEnabled = false
            mainTitleLabel.tag = 787878
            self.navBar?.subviews[0].addSubview(mainTitleLabel)
        } else {
            self.navBar?.subviews[0].viewWithTag(787878)?.removeFromSuperview()
            self.navigationItem.title = title
        }
    }
    
}
