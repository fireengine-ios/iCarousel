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
    @IBOutlet private weak var birthdayDetailView: ProfileBirthdayFieldView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let secretQuestionView = SetSecurityCredentialsView.initFromNib()
    
    //MARK: Vars
    private let keyboard = Typist.shared
    
    private var name: String?
    private var surname: String?
    private var email: String?
    private var number: String?
    private var birthday: String?

    private lazy var editButton = UIBarButtonItem(title: TextConstants.userProfileEditButton,
                                                  font: UIFont.TurkcellSaturaRegFont(size: 19),
                                                  tintColor: .white,
                                                  accessibilityLabel: TextConstants.userProfileEditButton,
                                                  style: .plain,
                                                  target: self,
                                                  selector: #selector(onEditButtonAction))
    
    private lazy var readyButton = UIBarButtonItem(title: TextConstants.userProfileDoneButton,
                                                   font: UIFont.TurkcellSaturaRegFont(size: 19),
                                                   tintColor: .white,
                                                   accessibilityLabel: TextConstants.userProfileDoneButton,
                                                   style: .plain,
                                                   target: self,
                                                   selector: #selector(onReadyButtonAction))

    //MARK: init / deinit
    deinit {
        keyboard.stop()
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        automaticallyAdjustsScrollViewInsets = false
        
        setupFields()
        configureKeyboard()

        configureNavBar()
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
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
    
    private func setupFields() {
        nameDetailView.title = TextConstants.userProfileName
        surnameDetailView.title = TextConstants.userProfileSurname
        emailDetailView.title = TextConstants.userProfileEmailSubTitle
        gsmDetailView.title = TextConstants.userProfileGSMNumberSubTitle
        birthdayDetailView.title = TextConstants.userProfileBirthday

        nameDetailView.responderOnNext = surnameDetailView
        surnameDetailView.responderOnNext = emailDetailView
        gsmDetailView.responderOnNext = birthdayDetailView
        emailDetailView.responderOnNext = SingletonStorage.shared.isTurkcellUser ?
            birthdayDetailView : gsmDetailView
        
        gsmDetailView.setupAsTurkcellGSMIfNeeded()
        emailDetailView.setupAsEmail()
        createSecretQuestionAndPasswordViews()
    }
    
    private func createSecretQuestionAndPasswordViews() {
        
        let passwordView = SetSecurityCredentialsView.initFromNib()
        passwordView.setupView(with: .password, title: TextConstants.userProfilePassword, description: "* * * * * * * * *", buttonTitle: TextConstants.userProfileChangePassword)
        passwordView.delegate = self
        stackView.insertArrangedSubview(passwordView, at: stackView.subviews.count)
        
        
        
        secretQuestionView.delegate = self
        secretQuestionView.setupView(with: .secretQuestion, title: TextConstants.userProfileSecretQuestion, description: TextConstants.userProfileSecretQuestionLabelPlaceHolder, buttonTitle: TextConstants.userProfileSetSecretQuestionButton)
        stackView.insertArrangedSubview(secretQuestionView, at: stackView.subviews.count)
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
        
        let rect = scrollView.convert(firstResponser.frame, to: scrollView)
            .offsetBy(dx: 0.0, dy: NumericConstants.firstResponderBottomOffset)
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
        button.fixEnabledState()
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
        configuresecretQuestionView(userInfo: userInfo)
    }
    
    private func configuresecretQuestionView(userInfo: AccountInfoResponse) {
        
        guard userInfo.hasSecurityQuestionInfo != nil, let _ = userInfo.hasSecurityQuestionInfo, let questionId = userInfo.securityQuestionId else  {
            return
        }
        
        let accountService = AccountService()
        accountService.getListOfSecretQuestions { [weak self] response in
            switch response {
            case .success( let questions):
                guard let question = questions.first(where: { $0.id == questionId }) else {
                    assertionFailure()
                    return
                }
                self?.secretQuestionView.setDesriptionLabel(question: question.text)
                
            case .failed(let error):
                print("error", error.localizedDescription)
            }
        }
        
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getPhoneNumber() -> String {
        return gsmDetailView.editableText ?? ""
    }
    
    func endSaving() {
        navigationItem.rightBarButtonItem?.fixEnabledState()
    }
    
    @objc private func onEditButtonAction() {
        nameDetailView.becomeFirstResponder()
        output.tapEditButton()
        saveFields()
    }
    
    @objc private func onReadyButtonAction() {
        guard name != nameDetailView.editableText ||
            surname != surnameDetailView.editableText ||
            email != emailDetailView.editableText ||
            number != gsmDetailView.editableText ||
            birthday != birthdayDetailView.editableText else {
                setupEditState(false)
                return
        }
        
        readyButton.isEnabled = false
        
        if email != emailDetailView.editableText {
            guard let email = emailDetailView.editableText, !email.isEmpty else {
                output.showError(error: TextConstants.emptyEmail)
                return
            }
            
            guard Validator.isValid(email: emailDetailView.editableText) else {
                output.showError(error: TextConstants.notValidEmail)
                return
            }
            
            let message = String(format: TextConstants.registrationEmailPopupMessage, emailDetailView.editableText ?? "")
            
            let controller = PopUpController.with(
                title: TextConstants.registrationEmailPopupTitle,
                message: message,
                image: .error,
                buttonTitle: TextConstants.ok,
                action: { [weak self] vc in
                    vc.close { [weak self] in
                        self?.output.tapReadyButton(name: self?.nameDetailView.editableText ?? "",
                                                    surname: self?.surnameDetailView.editableText ?? "",
                                                    email: self?.emailDetailView.editableText ?? "",
                                                    number: self?.gsmDetailView.editableText ?? "",
                                                    birthday: self?.birthdayDetailView.editableText ?? "")
                        self?.readyButton.fixEnabledState()
                    }
                })
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            output.tapReadyButton(name: nameDetailView.editableText ?? "",
                                  surname: surnameDetailView.editableText ?? "",
                                  email: emailDetailView.editableText ?? "",
                                  number: gsmDetailView.editableText ?? "",
                                  birthday: birthdayDetailView.editableText ?? "")
        }
    }
}

// MARK: - UITextFieldDelegate

extension UserProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case nameDetailView.getTextField():
            nameDetailView.responderOnNext?.becomeFirstResponder()
        case surnameDetailView.getTextField():
            surnameDetailView.responderOnNext?.becomeFirstResponder()
        case emailDetailView.getTextField():
            emailDetailView.responderOnNext?.becomeFirstResponder()
        case gsmDetailView.getTextField():
            gsmDetailView.responderOnNext?.becomeFirstResponder()
        case birthdayDetailView.getTextField():
            ///last field
            birthdayDetailView.resignFirstResponder()
        default:
            fatalError("Unknown responder")
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

extension UserProfileViewController: SetSecurityCredentialsViewDelegate {
    
    func setNewPasswordTapped() {
        output.tapChangePasswordButton()
    }
    
    func setNewQuestionTapped() {
        output.tapChangeSecretQuestionButton()
    }
}

