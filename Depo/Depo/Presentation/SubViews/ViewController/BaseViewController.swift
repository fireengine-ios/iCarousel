//
//  BaseViewController.swift
//  Depo
//
//  Created by Oleg on 13.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var keyboardHeight: CGFloat = 0
    
    var needShowTabBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabBarIfNeed()
    }
    
    func getMainYForView(view: UIView)->CGFloat{
        if (view.superview == self.view){
            return view.frame.origin.y
        }else{
            if (view.superview != nil){
                return view.frame.origin.y + getMainYForView(view:view.superview!)
            }else{
                return 0
            }
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
    }
    
    @objc func hideKeyboard() {
        
    }
    
    func searchActiveTextField(view: UIView) -> UITextField? {
        
        if let textField = view as? UITextField {
            if textField.isFirstResponder {
                return textField
            }
        }
        for subView in view.subviews {
            let textField = searchActiveTextField(view: subView)
            if (textField != nil){
                return textField
            }
        }
        return nil
    }
    
    func showTabBarIfNeed() {
        if isNeedShowTabBar(){
            let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
        else{
            let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
    
    func isNeedShowTabBar() -> Bool{
        return needShowTabBar
    }
    
}
