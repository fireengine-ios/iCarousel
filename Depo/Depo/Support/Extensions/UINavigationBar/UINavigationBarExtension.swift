//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

//TODO: to be dropped
extension UIViewController {
    func backButtonForNavigationItem(title: String) {
        navigationItem.backButtonTitle = title
    }
    
    func setNavigationTitle(title: String) {
        navigationItem.title = title
    }
    
    func setNavigationRightBarButton(title: String, target: AnyObject, action: Selector) {
        guard target.responds(to: action) else {
            assertionFailure()
            return
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, target: target, selector: action)
    }
}
