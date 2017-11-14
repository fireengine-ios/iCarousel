//
//  PasscodeManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PasscodeManager: NSObject {
    
    static let shared = PasscodeManager()
    
    let passcodeStorage = PasscodeStorageDefaults()
    weak var delegate: PasscodeEnterDelegate?
    
    var isOn: Bool {
        return !passcodeStorage.isEmpty
    }
    
    lazy var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindowLevelNormal + 1
        return window
    }()
    
    lazy var controller: PasscodeEnterViewController = {
        return PasscodeEnterModuleInitializer(delegate: self, type: .validate).viewController as! PasscodeEnterViewController
    }()
    
    override private init() {
        super.init()
        window.rootViewController = controller
        
        NotificationCenter.default.addObserver(self, selector: #selector(show), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func show() {
        if isOn {
//            if !window.isKeyWindow {
//                window.becomeKey()
//            }
//            window.isHidden = false
            window.makeKeyAndVisible()
            controller.passcodeView.set(type: .validateWithBiometrics)
            
//            controller.passcodeView.passcodeInputView.resignFirstResponder()
            controller.passcodeView.passcodeInputView.becomeFirstResponder()
            
//            if !controller.passcodeView.passcodeInputView.isFirstResponder {
//                controller.passcodeView.passcodeInputView.becomeFirstResponder()
//            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.controller.passcodeView.passcodeInputView.becomeFirstResponder()
//            }
            
            
            
//            controller.passcodeView.becomeFirstResponder()
        }
    }
    
    func hide() {
        window.isHidden = true
//        window.resignKey()
        controller.passcodeView.passcodeInputView.resignFirstResponder()
//        window.endEditing(true)
    }
}
extension PasscodeManager: PasscodeEnterDelegate {
    func finishPasscode(with type: PasscodeInputViewType) {
        hide()
    }
}
