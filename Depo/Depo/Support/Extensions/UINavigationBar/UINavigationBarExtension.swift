//
//  UINavigationBarExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

//TODO: Facelift: to be dropped
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
    
    func setTextFieldInNavigationBar(withDelegate delegate: UITextFieldDelegate? = nil) {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textField.font = .appFont(.medium, size: 16)
        textField.textColor = AppColor.darkBlue.color
        textField.textAlignment = .center
        let collageName = StringConstants.collageName
        if  collageName != "+New Collage" {
            textField.text = collageName
        } else {
            textField.text = "+New Collage"
        }
        textField.delegate = delegate
        navigationItem.titleView = textField
    }

    var navTextField: UITextField? {
        return navigationItem.titleView as? UITextField
    }
}
