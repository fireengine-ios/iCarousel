//
//  UserProfileUserProfileViewController.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class UserProfileViewController: BaseViewController, UserProfileViewInput {
    var output: UserProfileViewOutput!
    
    //MARK: IBOutlet
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var viewForContent: UIView!
    
    @IBOutlet private weak var nameDetailView: ProfileFieldView!
    @IBOutlet private weak var surnameDetailView: ProfileFieldView!
    @IBOutlet private weak var emailDetailView: ProfileFieldView!
    @IBOutlet private weak var gsmDetailView: ProfileFieldView!
    @IBOutlet private weak var birthdayDetailView: ProfileFieldView!
    @IBOutlet private weak var passwordDetailView: ProfileFieldView!
    
    @IBOutlet private weak var changePasswordButton: UIButton!
    
    //MARK: Vars
    private let keyboard = Typist.shared
    
    private var name: String?
    private var surname: String?
    private var email: String?
    private var number: String?
    private var birthday: String?

    var editButton: UIBarButtonItem?
    var readyButton: UIBarButtonItem?

    //MARK: init / deinit
    deinit {
        keyboard.stop()
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        let attributedString = NSAttributedString(string: TextConstants.userProfileChangePassword,
                                                  attributes: [
                                                    .font : UIFont.TurkcellSaturaMedFont(size: 15),
                                                    .foregroundColor : UIColor.lrTealish,
                                                    .underlineStyle : NSUnderlineStyle.styleSingle.rawValue
            ])
    
        changePasswordButton.setAttributedTitle(attributedString, for: .normal)
    
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
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        configureKeyboard()
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    //MARK: Utility Methods(Private)
    fileprivate func configureKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }
                self.updateContentInsetWithKeyboardFrame(options.endFrame)
                self.scrollToFirstResponderIfNeeded(animated: false)
            }
            .on(event: .willHide) { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                var inset = self.scrollView.contentInset
                inset.bottom = 0
                
                self.scrollView.contentInset = inset
                self.scrollView.setContentOffset(.zero, animated: true)
            }
            .start()
    }
    
    private func updateContentInsetWithKeyboardFrame(_ keyboardFrame: CGRect) {
        let screenHeight = UIScreen.main.bounds.height
        let bottomInset = keyboardFrame.height + screenHeight - keyboardFrame.maxY
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    private func scrollToFirstResponderIfNeeded(animated: Bool) {
        guard let firstResponser = view.firstResponder as? UIView else {
            return
        }
        
        let rect = scrollView.convert(view.frame, to: scrollView).offsetBy(dx: 0.0, dy: 50.0)
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.myProfile)
    }
    
    private func saveFields() {
        name = nameDetailView.editableText
        surname = surnameDetailView.editableText
        email = emailDetailView.editableText
        number = gsmDetailView.editableText
        birthday = birthdayDetailView.editableText
    }

    //MARK: Utility Methods(Public)
    func setupEditState(_ isEdit: Bool) {
        let button = isEdit ? readyButton : editButton
        button?.isEnabled = true
        navigationItem.setRightBarButton(button, animated: true)
        
        nameDetailView.isEditState = isEdit
        surnameDetailView.isEditState = isEdit
        emailDetailView.isEditState = isEdit
        gsmDetailView.isEditState = isEdit
        birthdayDetailView.isEditState = isEdit
    }
    
    func configurateUserInfo(userInfo: AccountInfoResponse) {
        nameDetailView.configure(with: userInfo.name, delegate: self)
        surnameDetailView.configure(with: userInfo.surname, delegate: self)
        emailDetailView.configure(with: userInfo.email, delegate: self)
        gsmDetailView.configure(with: userInfo.phoneNumber, delegate: self)
        let birthday = (userInfo.dob ?? "").replacingOccurrences(of: "-", with: " ")
        birthdayDetailView.configure(with: birthday, delegate: self)
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getPhoneNumber() -> String {
        return gsmDetailView.editableText ?? ""
    }
    
    func endSaving() {
        readyButton?.isEnabled = true
    }
    
    //MARK: Actions
    @IBAction private func onChangePasswordTap(_ sender: Any) {
        output.tapChangePasswordButton()
    }
    
    @objc private func onEditButtonAction() {
        nameDetailView.becomeFirstResponder()
        output.tapEditButton()
        saveFields()
    }
    
    @objc private func onReadyButtonAction() {
        guard name == nameDetailView.editableText,
            surname == surnameDetailView.editableText,
            email == emailDetailView.editableText,
            number == gsmDetailView.editableText,
            birthday == birthdayDetailView.editableText else {
                setupEditState(false)
                return
        }
        
        if email != emailDetailView.editableText {
            guard let email = emailDetailView.editableText, !email.isEmpty else {
                output.showError(error: TextConstants.emptyEmail)
                return
            }
            
            guard Validator.isValid(email: emailDetailView.editableText) else {
                output.showError(error: TextConstants.notValidEmail)
                return
            }
            
            readyButton?.isEnabled = false
            
            let message = String(format: TextConstants.registrationEmailPopupMessage, emailDetailView.editableText ?? "")
            
            let controller = PopUpController.with(
                title: TextConstants.registrationEmailPopupTitle,
                message: message,
                image: .error,
                buttonTitle: TextConstants.ok,
                action: { [weak self] vc in
                    vc.close { [weak self] in
                        self?.output.setNewBirthday(self?.birthdayDetailView.editableText ?? "")

                        self?.output.tapReadyButton(name: self?.nameDetailView.editableText ?? "",
                                                    surname: self?.surnameDetailView.editableText ?? "",
                                                    email: self?.emailDetailView.editableText ?? "",
                                                    number: self?.gsmDetailView.editableText ?? "")
                        self?.readyButton?.isEnabled = true
                    }
                })
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            output.setNewBirthday(birthdayDetailView.editableText ?? "")
            
            output.tapReadyButton(name: nameDetailView.editableText ?? "",
                                        surname: surnameDetailView.editableText ?? "",
                                        email: emailDetailView.editableText ?? "",
                                        number: gsmDetailView.editableText ?? "")
            readyButton?.isEnabled = false
        }
    }
}

// MARK: - UITextFieldDelegate

extension UserProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let type = ProfileFieldType(rawValue: textField.tag) else {
            return true
        }
        
        switch type {
        case .firstName:
            surnameDetailView.becomeFirstResponder()
        case .secondName:
            emailDetailView.becomeFirstResponder()
        case .email:
            gsmDetailView.becomeFirstResponder()
        case .gsmNumber:
            birthdayDetailView.becomeFirstResponder()
        case .birthday:
            passwordDetailView.becomeFirstResponder()
        case .password:
            break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if textField == emailDetailView.getTextField() {
                textField.text = text.removingWhiteSpaces()
            } else if textField == nameDetailView.getTextField() ||
                textField == nameDetailView.getTextField() {
                    textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameDetailView.getTextField() ||
            textField == surnameDetailView.getTextField(),
            textField.text?.count == NumericConstants.maxStringLengthForUserProfile {
            return false
        }
        
        return !(string == " " && textField == emailDetailView.getTextField())
    }
}
