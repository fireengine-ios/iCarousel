//
//  UIViewController+NavBar.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/18/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

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
        navBar?.topItem?.backBarButtonItem?.tintColor = .white
        
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
