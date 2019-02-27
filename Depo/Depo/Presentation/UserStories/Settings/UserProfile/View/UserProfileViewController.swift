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
    
    @IBOutlet var keyboardHideManager: KeyboardHideManager! /// not weak
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewForContent: UIView!
    
    @IBOutlet weak var nameSubTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailSubTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var gsmNumberSubTitle: UILabel!
    @IBOutlet weak var gsmNumberTextField: UITextField!
    
    var editButton: UIBarButtonItem?
    var readyButton: UIBarButtonItem?
    
    private var name: String?
    private var email: String?
    private var number: String?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
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
        
        // font: .TurkcellSaturaRegFont(size: 19) ///maybe will be need
        editButton = UIBarButtonItem(title: TextConstants.userProfileEditButton,
                                     target: self,
                                     selector: #selector(onEditButtonAction))
        
        // font: .TurkcellSaturaRegFont(size: 19) ///maybe will be need
        readyButton = UIBarButtonItem(title: TextConstants.userProfileDoneButton,
                                      target: self,
                                      selector: #selector(onReadyButtonAction))
        
        configureNavBar()
        navigationBarWithGradientStyle()
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.backTitle)
        
        navigationController?.navigationItem.title = TextConstants.backTitle
    }

    // MARK: ViewInput
    func setupInitialState() {
        
    }
    
    func setupEditState(_ isEdit: Bool) {
        let button = isEdit ? readyButton : editButton
        button?.isEnabled = true
        navigationItem.setRightBarButton(button, animated: true)
        nameTextField.isUserInteractionEnabled = isEdit
        emailTextField.isUserInteractionEnabled = isEdit
        gsmNumberTextField.isUserInteractionEnabled = isEdit
    }
    
    func configurateUserInfo(userInfo: AccountInfoResponse) {
        var string = userInfo.name ?? ""
        if let surname = userInfo.surname, !surname.isEmpty {
            if !string.isEmpty {
                string = string + " "
            }
            string = string + surname
        }
        
        nameTextField.text = string
        emailTextField.text = userInfo.email
        gsmNumberTextField.text = userInfo.phoneNumber
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getPhoneNumber() -> String {
        return gsmNumberTextField.text ?? ""
    }
    
    func endSaving() {
        readyButton?.isEnabled = true
    }
    
    // MARK: ButtonsAction
    
    @IBAction func onValueChanged() {}
    
    @objc func onEditButtonAction() {
        nameTextField.becomeFirstResponder()
        output.tapEditButton()
        saveFields()
    }
    
    /// save for "check for no changes" in onReadyButtonAction
    private func saveFields() {
        name = nameTextField.text
        email = emailTextField.text
        number = gsmNumberTextField.text
    }
    
    @objc func onReadyButtonAction() {
        /// check for no changes
        if name == nameTextField.text, email == emailTextField.text, number == gsmNumberTextField.text {
            setupEditState(false)
            return
        }
        
        if email != emailTextField.text {
            
            if emailTextField.text?.isEmpty == true {
                output.showError(error: TextConstants.emptyEmail)
                return
            }
            
            guard Validator.isValid(email: emailTextField.text) else {
                output.showError(error: TextConstants.notValidEmail)
                return
            }
            
            
            readyButton?.isEnabled = false
            
            let message = String(format: TextConstants.registrationEmailPopupMessage, emailTextField.text ?? "")
            
            let controller = PopUpController.with(
                title: TextConstants.registrationEmailPopupTitle,
                message: message,
                image: .error,
                buttonTitle: TextConstants.ok,
                action: { [weak self] vc in
                    vc.close { [weak self] in
                        self?.output.tapReadyButton(name: self?.nameTextField.text ?? "", email: self?.emailTextField.text ?? "", number: self?.gsmNumberTextField.text ?? "")
                        self?.readyButton?.isEnabled = true
                    }
                })
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            readyButton?.isEnabled = false
            output.tapReadyButton(name: nameTextField.text ?? "", email: emailTextField.text ?? "", number: gsmNumberTextField.text ?? "")
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !(textField == gsmNumberTextField && output.isTurkcellUser())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, textField == emailTextField {
            textField.text = text.removingWhiteSpaces()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " && textField == emailTextField {
            return false
        }
        
        return true
    }
    
}
