//
//  UserProfileUserProfileViewController.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UserProfileViewController: BaseViewController, UserProfileViewInput, UITextFieldDelegate {

    var output: UserProfileViewOutput!
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var viewForContent: UIView!
    
    @IBOutlet weak var nameSubTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailSubTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var gsmNumberSubTitle: UILabel!
    @IBOutlet weak var gsmNumberTextField: UITextField!
    
    var editButton: UIBarButtonItem?

    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameSubTitle.text = TextConstants.userProfileNameAndSurNameSubTitle
        nameSubTitle.textColor = ColorConstants.textLightGrayColor
        nameSubTitle.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        nameTextField.textColor = ColorConstants.textGrayColor
        nameTextField.font = UIFont.TurkcellSaturaBolFont(size: 21)
        
        emailSubTitle.text = TextConstants.userProfileEmailSubTitle
        emailSubTitle.textColor = ColorConstants.textLightGrayColor
        emailSubTitle.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        emailTextField.textColor = ColorConstants.textGrayColor
        emailTextField.font = UIFont.TurkcellSaturaBolFont(size: 21)
        
        gsmNumberSubTitle.text = TextConstants.userProfileGSMNumberSubTitle
        gsmNumberSubTitle.textColor = ColorConstants.textLightGrayColor
        gsmNumberSubTitle.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        gsmNumberTextField.textColor = ColorConstants.textGrayColor
        gsmNumberTextField.font = UIFont.TurkcellSaturaBolFont(size: 21)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        button.setTitle(TextConstants.userProfileEditButton, for: .normal)
        button.addTarget(self, action: #selector(onEditButton), for: .touchUpInside)
        editButton = UIBarButtonItem(customView: button)
        
        let text = TextConstants.userProfileBottomLabelText1 + "\n\n" + TextConstants.userProfileBottomLabelText2
        let string = text as NSString
        let range = string.range(of: TextConstants.userProfileBottomLabelText2)
        let attributedText = NSMutableAttributedString(string: text)
        
        let fontSize:CGFloat = 16
        
        let font1 = UIFont.TurkcellSaturaDemFont(size: fontSize)
        let font2 = UIFont.TurkcellSaturaItaFont(size: fontSize)
        let r1 = NSRange(location: 0, length: range.location)
        let r2 = NSRange(location: range.location, length: range.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font1, range: r1)
        attributedText.addAttribute(NSAttributedStringKey.font, value: font2, range: r2)
        
        scrollView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        
        output.viewIsReady()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self);
    }
    
    override func showKeyBoard(notification: NSNotification){
        super.showKeyBoard(notification: notification)
        let spaceUnderContentView = view.frame.size.height - (viewForContent.frame.origin.y + viewForContent.frame.size.height)
        if (spaceUnderContentView < keyboardHeight + 10){
            let bottomInset = keyboardHeight + 10 - spaceUnderContentView
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset + keyboardHeight, right: 0)
            
            let textField = searchActiveTextField(view: self.view)
            
            let yTextField = textField!.frame.origin.y + textField!.frame.size.height + 10
            if (view.frame.size.height - yTextField < keyboardHeight){
                let y = yTextField - (view.frame.size.height - keyboardHeight - 64)
                if (y > 0){
                    let point = CGPoint(x: 0, y: y)
                    scrollView.setContentOffset(point, animated: false)
                }
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
        view.endEditing(true)
        let point = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(point, animated: false)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }


    // MARK: ViewInput
    func setupInitialState() {
        
    }
    
    func configurateUserInfo(userInfo: AccountInfoResponse){
        var string: String = ""
        if let name_ = userInfo.name{
            string = string + name_
        }
        
        if let surName_ = userInfo.surname{
            if (string.characters.count > 0){
                string = string + " "
            }
            string = string + surName_
        }
        nameTextField.text = string
        
        emailTextField.text = userInfo.email
        
        gsmNumberTextField.text = userInfo.phoneNumber
    }
    
    func setEditButtonEnable(enable: Bool){
        if (enable){
            self.navigationItem.rightBarButtonItem = editButton
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func getNavigationController() -> UINavigationController?{
        return navigationController
    }
    
    // MARK: ButtonsAction
    
    @IBAction func onValueChanged(){
        output.fieldsValueChanged(name: nameTextField.text ?? "", email: emailTextField.text ?? "", number: gsmNumberTextField.text ?? "")
    }
    
    @objc func onEditButton(){
        output.onEditButton(name: nameTextField.text ?? "", email: emailTextField.text ?? "", number: gsmNumberTextField.text ?? "")
    }
    
    @IBAction func onHideKeyboardButton(){
        if let textField = searchActiveTextField(view: view){
            textField.resignFirstResponder()
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let view: UIView? = viewForContent.viewWithTag(tag + 1)
        guard let nextTextField = view as! UITextField!  else {
            return true
        }
        nextTextField.becomeFirstResponder()
        
        return true
    }
}
