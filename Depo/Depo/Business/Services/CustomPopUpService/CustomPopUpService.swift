//
//  MessageService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/16/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CustomPopUpAlertActions: class {
    func cancelationAction()
    func otherAction()
}

class CustomPopUp {
    
    weak var delegate: CustomPopUpAlertActions?
    
    static let sharedInstance = CustomPopUp()
    
//    var customAlertView: CustomPopUpAlert? //TODO: remove this, add buttons in the class intself
    
    var popUpAlertsStack: [CustomPopUpAlert] = []
    
    private var shadowView: UIView?
    
    
    //MARK: - New
    func showCustomInfoAlert(withTitle title: String, titleAligment: NSTextAlignment = .center,
                         withText text: String, warningTextAligment: NSTextAlignment = .center,
                         okButtonText buttonText: String,
                         isShadowViewShown: Bool = true,
                         firstCustomAction: UIButtonCustomAction? = nil) {
        
        guard let customAlert = self.setupBaseAlert(withTitle: title, titleAligment: titleAligment, withWarningText: text, warningTextAligment: warningTextAligment) else {
            return
        }
        self.setupMiddleButton(inCustomAlert: customAlert, withLabeltext: buttonText, isShadowViewShown: isShadowViewShown, firstCustomAction: firstCustomAction)
        customAlert.setup(asType: .info)
        customAlert.alertLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
    }
    
    func showCustomSuccessAlert(withTitle title: String, titleAligment: NSTextAlignment = .center,
                             withText text: String, warningTextAligment: NSTextAlignment = .center,
                             okButtonText buttonText: String,
                             isShadowViewShown: Bool = true,
                             firstCustomAction: UIButtonCustomAction? = nil) {
        
        guard let customAlert = self.setupBaseAlert(withTitle: title, titleAligment: titleAligment, withWarningText: text, warningTextAligment: warningTextAligment) else {
            return
        }
        self.setupMiddleButton(inCustomAlert: customAlert, withLabeltext: buttonText, isShadowViewShown: isShadowViewShown, firstCustomAction: firstCustomAction)
        customAlert.setup(asType: .success)
        customAlert.alertLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
    }
    
    func showCustomAlert(withTitle title: String = TextConstants.errorAlert, titleAligment: NSTextAlignment = .left,
                         withText text: String, warningTextAligment: NSTextAlignment = .left,
                         okButtonText buttonText: String, isShadowViewShown: Bool = true,
                         firstCustomAction: UIButtonCustomAction? = nil) {
        
        guard let customAlert = self.setupBaseAlert(withTitle: title, titleAligment: titleAligment, withWarningText: text, warningTextAligment: warningTextAligment) else {
            return
        }
        
        var firstCustomAction = firstCustomAction
        if firstCustomAction == nil {
            firstCustomAction = {
                self.hideAll()
            }
        }
        
        customAlert.setup(asType: .regular)
        self.setupMiddleButton(inCustomAlert: customAlert, withLabeltext: buttonText,
                               isShadowViewShown: isShadowViewShown, firstCustomAction: firstCustomAction)
    }
    
    func showCustomAlert(withTitle title: String = "ERROR", titleAligment: NSTextAlignment = .left,
                         withText text: String,  warningTextAligment: NSTextAlignment = .left,
                         firstButtonText: String, secondButtonText: String,
                         isShadowViewShown: Bool = true,
                         firstCustomAction: UIButtonCustomAction? = nil, secondCustomAction: UIButtonCustomAction? = nil) {
        guard let customAlert = self.setupBaseAlert(withTitle: title, titleAligment: titleAligment, withWarningText: text, warningTextAligment: warningTextAligment) else {
            return
        }
        customAlert.setup(asType: .regular)
        self.setupTwoButtons(inCustomAlert: customAlert, firstButtonText: firstButtonText,
                             secondButtonText: secondButtonText, isShadowViewShown: isShadowViewShown,
                             firstCustomAction: firstCustomAction, secondCustomAction: secondCustomAction)
    }
    
    private func setupBaseAlert(withTitle title: String, titleAligment: NSTextAlignment,
                                withWarningText text: String, warningTextAligment: NSTextAlignment) -> CustomPopUpAlert? {
        guard let appDelegate = UIApplication.shared.delegate,let window: UIWindow = appDelegate.window as? UIWindow else {
            return nil
        }
        guard let customAlert = CustomPopUpAlert.loadFromNib() else {
            return nil
        }
        customAlert.alertTextView.font = UIFont.TurkcellSaturaRegFont(size: 18)
        customAlert.alertTextView.text = text
        customAlert.alertTextView.textAlignment = warningTextAligment
        customAlert.alertLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        customAlert.alertLabel.text = title
        customAlert.alertLabel.textAlignment = titleAligment
        
        
        if shadowView == nil {
            createShadowView(onView: window)
        }
        
        window.addSubview(customAlert)
        self.setupCenterConstraints(forAlerView: customAlert, inSuperView: window)
        
        window.layoutIfNeeded()
        
        popUpAlertsStack.append(customAlert)//adding base alert ot a stack

        return customAlert
    }
    
    private func setupCenterConstraints(forAlerView view: UIView, inSuperView superView: UIView) {
        superView.addConstraint(NSLayoutConstraint(item: superView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        superView.addConstraint(NSLayoutConstraint(item: superView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    private func setupMiddleButton(inCustomAlert customAlert: CustomPopUpAlert, withLabeltext text: String,
                                   isShadowViewShown: Bool = true,
                                   firstCustomAction: UIButtonCustomAction?) {
        let button = createButton(withSelector: #selector(firstAction), andTitle: text, andFontName: UIFont.TurkcellSaturaBolFont(size: 18), customAction: firstCustomAction)
        customAlert.twoButtonsContainer.isHidden = true
        customAlert.buttonContainer.addSubview(button)
        
        let botConstraint = NSLayoutConstraint(item: customAlert.buttonContainer, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1, constant: 6)
        let topConstraint = NSLayoutConstraint(item: customAlert.buttonContainer, attribute: .top, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1, constant: 6)
        
        let leading = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: customAlert.buttonContainer, attribute: .leading, multiplier: 1, constant: 50)
        
        let trailing = NSLayoutConstraint(item: customAlert.buttonContainer, attribute: .trailing, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1, constant: 50)
        
        customAlert.buttonContainer.addConstraints([botConstraint,topConstraint, leading, trailing])
        
        customAlert.buttonContainer.layoutIfNeeded()
    }
    
    private func setupTwoButtons(inCustomAlert customAlert: CustomPopUpAlert,
                                 firstButtonText firstText: String, secondButtonText secondText: String,
                                 isShadowViewShown: Bool = true,
                                 firstCustomAction: UIButtonCustomAction?, secondCustomAction: UIButtonCustomAction?) {
        
        let firstButton = createButton(withSelector: #selector(firstAction(sender:)), andTitle: firstText,
                                       andFontName: UIFont.TurkcellSaturaRegFont(size: 18), customAction: firstCustomAction)
        let secondButton = createButton(withSelector: #selector(secondAction), andTitle: secondText,
                                        andFontName: UIFont.TurkcellSaturaBolFont(size: 18), customAction: secondCustomAction)
        customAlert.twoButtonsContainer.addSubview(firstButton)
        customAlert.twoButtonsContainer.addSubview(secondButton)
        
        //TODO: change it to visual constraints
        let button1BotConstraint = NSLayoutConstraint(item: firstButton, attribute: .bottom, relatedBy: .equal, toItem: customAlert.twoButtonsContainer, attribute: .bottom, multiplier: 1, constant: -6)
        let button1TopConstraint = NSLayoutConstraint(item: customAlert.twoButtonsContainer, attribute: .top, relatedBy: .equal, toItem: firstButton, attribute: .top, multiplier: 1, constant: -7)
        
        
        let button1Leading = NSLayoutConstraint(item: firstButton, attribute: .leading, relatedBy: .equal, toItem: customAlert.twoButtonsContainer, attribute: .leading, multiplier: 1, constant: 15)
        
        let button1Trailing = NSLayoutConstraint(item: customAlert.verticalButtonSeparator, attribute: .trailing, relatedBy: .equal, toItem: firstButton, attribute: .trailing, multiplier: 1, constant: 15)
        
        customAlert.twoButtonsContainer.addConstraints([button1BotConstraint, button1TopConstraint, button1Leading, button1Trailing])
        
        
        //------second button
//        secondButton.backgroundColor = UIColor.red
        let button2BotConstraint = NSLayoutConstraint(item: secondButton, attribute: .bottom, relatedBy: .equal, toItem: customAlert.twoButtonsContainer, attribute: .bottom, multiplier: 1, constant: -6)
        let button2TopConstraint = NSLayoutConstraint(item: customAlert.twoButtonsContainer, attribute: .top, relatedBy: .equal, toItem: secondButton, attribute: .top, multiplier: 1, constant: -7)
        
        
        let button2Leading = NSLayoutConstraint(item: secondButton, attribute: .leading, relatedBy: .equal, toItem: customAlert.verticalButtonSeparator, attribute: .leading, multiplier: 1, constant: 15)
        
        let button2Trailing = NSLayoutConstraint(item: customAlert.twoButtonsContainer, attribute: .trailing, relatedBy: .equal, toItem: secondButton, attribute: .trailing, multiplier: 1, constant: 15)
        
        customAlert.twoButtonsContainer.addConstraints([button2BotConstraint, button2TopConstraint, button2Leading, button2Trailing])
        
        customAlert.twoButtonsContainer.layoutIfNeeded()
        
    }
    
    @discardableResult
    private func createShadowView(onView superView: UIView) -> UIView {
        let view = UIView(frame: CGRect())
        view.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(view)
        
        view.backgroundColor = UIColor.black
        view.alpha = 0.49
        self.setupShadowViewConstraints(forShadowView: view, withSuperView: superView)
        
        shadowView = view
        superView.layoutIfNeeded()
        return view
    }
    
    private func setupShadowViewConstraints(forShadowView shadowView: UIView, withSuperView superView: UIView) {
        let botAndTop = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[shadow]-0-|", options: [], metrics: nil, views: ["shadow" : shadowView])
        let leadingTrailing = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[shadow]-0-|", options: [], metrics: nil, views: ["shadow" : shadowView])
        
        superView.addConstraints(botAndTop + leadingTrailing)
    }
    
    private func createButton(withSelector: Selector, andTitle title: String,
                              andFontName font: UIFont, customAction: UIButtonCustomAction?) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.translatesAutoresizingMaskIntoConstraints = false
        if let unwrapedAction = customAction {
            button.actionHandle(controlEvents: .touchUpInside, ForAction: unwrapedAction)
        } else {
            button.addTarget(self, action: withSelector, for: .touchUpInside)
        }
        
        button.setTitleColor(ColorConstants.blueColor, for: .normal)

        return button
    }
    
    private func hideShadowView() {
        if popUpAlertsStack.count <= 1 {
            shadowView?.removeFromSuperview()
            shadowView = nil
        }
    }
    
    private func hideTopAlert() {
        popUpAlertsStack.last?.removeFromSuperview()
        popUpAlertsStack.removeLast()
    }
    
    @objc func firstAction(sender: Any) {
        delegate?.cancelationAction()
        hideAll()
        
    }
    
    @objc func secondAction() {
        self.delegate?.otherAction()
        hideAll()
    }
    
     func hideAll() {
        hideShadowView()
        hideTopAlert()
    }
}
