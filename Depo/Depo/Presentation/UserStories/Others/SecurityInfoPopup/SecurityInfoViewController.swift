//
//  SecurityInfoViewController.swift
//  Lifebox
//
//  Created by Burak Donat on 12.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import Typist

enum SecurityScreenEntryType {
    case recoveryMail
    case securityQuestion
    case all
}

final class SecurityInfoViewController: BaseViewController, NibInit, KeyboardHandler {

    //MARK: -IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.numberOfLines = 0
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.securityPopupHeader)
        }
    }
    
    @IBOutlet private weak var bottomLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.securityPopupBody)
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 20
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            
            newValue.addArrangedSubview(recoveryEmailView)
            newValue.addArrangedSubview(securityQuestionView)
            newValue.addArrangedSubview(secretAnswerView)
            newValue.addArrangedSubview(captchaView)
        }
    }
    
    @IBOutlet private weak var saveButton: DarkBlueButton! {
        willSet {
            newValue.isEnabled = false
            newValue.setTitle(TextConstants.save, for: .normal)
        }
    }
    
    //MARK: -Properties
    private lazy var answer = SecretQuestionWithAnswer()
    private var questions = [SecretQuestionsResponse]()
    private let accountService = AccountService()
    private let keyboard = Typist()
    
    private var recoveryEmailOperation: (isSuccess: Bool?, errorMessage: String?)?
    private var securityQuestionOperation: (isSuccess: Bool?, errorMessage: SetSecretQuestionErrors?)?

    private lazy var recoveryEmailView: ProfileEmailFieldView = {
        let newValue = ProfileEmailFieldView()
        newValue.titleLabel.text = localized(.profileRecoveryMail)
        newValue.subtitleLabel.text = localized(.profileRecoveryMailDescription)
        newValue.textField.quickDismissPlaceholder = localized(.profileRecoveryMailHint)
        newValue.infoButton.isHidden = true
        return newValue
    }()
    
    private let securityQuestionView: SecurityQuestionView  = {
        let view = SecurityQuestionView.initFromNib()
        return view
    }()
    
    private let secretAnswerView: ProfileTextEnterView = {
        let view = ProfileTextEnterView()
        view.titleLabel.text = TextConstants.userProfileSecretQuestionAnswer
        return view
    }()
    
    private let captchaView: CaptchaView = {
        let view = CaptchaView()
        view.updateCaptcha()
        return view
    }()
    
    private lazy var closeSelfButton = UIBarButtonItem(image: nil,
                                                        style: .plain,
                                                        target: self,
                                                        action: nil)
    
    
    
    var fromSettings: Bool = true
    var fromHomeScreen: Bool = true
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        initSetup()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
        setupNavigation()
     }
    
    //MARK: -Helpers
    private func initSetup() {
        securityQuestionView.delegate = self
        secretAnswerView.textField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        captchaView.captchaAnswerTextField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        recoveryEmailView.textField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        addTapGestureToHideKeyboard()
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = closeSelfButton
        
        title = TextConstants.userProfileSecretQuestion
        
    }
    
    private func setSaveButton(isActive: Bool) {
        saveButton.isEnabled = isActive
    }
    
    @objc private func closeSelf() {
        
        if fromHomeScreen {
            navigationController?.popViewController(animated: true)
        } else if !fromSettings {
            goToTabbarScreen()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func goToTabbarScreen() {
        DispatchQueue.toMain {
            let router = RouterVC()
            router.setNavigationController(controller: router.tabBarScreen)
        }
    }
    
    @objc private func checkButtonStatus() {
        guard let secretAnswer = secretAnswerView.textField.text,
              let recoveryEmail = recoveryEmailView.textField.text,
              let captchaAnswer = captchaView.captchaAnswerTextField.text else {
                  setSaveButton(isActive: false)
                  return
              }
        
        let type = SingletonStorage.shared.signUpTypeForAppleGoogle
        let shouldButtonActive = type == AppleGoogleUserType.apple.value ? (!recoveryEmail.isEmpty && !captchaAnswer.isEmpty) : (!secretAnswer.isEmpty && !captchaAnswer.isEmpty) || !recoveryEmail.isEmpty
        
        setSaveButton(isActive: shouldButtonActive)
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                self?.scrollViewBottomConstraint.constant = -options.endFrame.height
                self?.view.layoutIfNeeded()
            }
            .on(event: .didShow) { [weak self] _ in
                self?.scrollView.scrollToBottom(animated: true)
            }
            .on(event: .willHide) { [weak self] options in
                self?.scrollViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
            .start()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        showSpinnerIncludeNavigationBar()
        answer.questionAnswer = secretAnswerView.textField.text
        captchaView.hideErrorAnimated()
        secretAnswerView.hideSubtitleAnimated()
        
        securityQuestionOperation = nil
        recoveryEmailOperation = nil
        
        guard let secretAnswer = secretAnswerView.textField.text,
              let recoveryEmail = recoveryEmailView.textField.text else {
                  hideSpinnerIncludeNavigationBar()
                  return
              }

        if !recoveryEmail.isEmpty && !Validator.isValid(email: recoveryEmail) {
            hideSpinnerIncludeNavigationBar()
            UIApplication.showErrorAlert(message: localized(.profileRecoveryEmailIsInvalid))
            return
        }
        
        let myGroup = DispatchGroup()

        if !recoveryEmail.isEmpty {
            myGroup.enter()
            setRecoveryEmail(with: recoveryEmail) {
                myGroup.leave()
            }
        }
        
        if !secretAnswer.isEmpty {
            myGroup.enter()
            getQuestions { [weak self] questions in
                self?.updateSecurityQuestion(questions: questions) {
                    myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            self.handleApiCalls()
        }
        SingletonStorage.shared.signUpTypeForAppleGoogle = AppleGoogleUserType.other.value
    }
    
    private func handleApiCalls() {
        if securityQuestionOperation == nil && recoveryEmailOperation != nil {
            recoveryEmailOperation?.isSuccess == true ? questionWasSuccessfullyUpdated(type: .recoveryMail)
            : UIApplication.showErrorAlert(message: recoveryEmailOperation?.errorMessage ?? "")
            return
        }
        
        if securityQuestionOperation != nil && recoveryEmailOperation == nil {
            securityQuestionOperation?.isSuccess == true ? questionWasSuccessfullyUpdated(type: .securityQuestion)
            : handleServerErrors(securityQuestionOperation?.errorMessage ?? .unknown)
            return
        }
        
        if securityQuestionOperation != nil && recoveryEmailOperation != nil {
            if securityQuestionOperation?.isSuccess == true && recoveryEmailOperation?.isSuccess == true {
                questionWasSuccessfullyUpdated(type: .all)
            } else if securityQuestionOperation?.isSuccess == true && recoveryEmailOperation?.isSuccess == false {
                showSecurityWarningPopup(errorMessage: recoveryEmailOperation?.errorMessage ?? "",
                                         warningType: .email)
            } else if securityQuestionOperation?.isSuccess == false && recoveryEmailOperation?.isSuccess == true {
                showSecurityWarningPopup(errorMessage: securityQuestionOperation?.errorMessage?.localizedDescription ?? "",
                                         warningType: .securityQuestion)
            }  else if securityQuestionOperation?.isSuccess == false && recoveryEmailOperation?.isSuccess == false {
                UIApplication.showErrorAlert(message: recoveryEmailOperation?.errorMessage ?? "")
            }
        }
    }
    
    private func showSecurityWarningPopup(errorMessage: String, warningType: SecurityPopupWarningType) {
                let router = RouterVC()
                router.popViewController()
                let popup = router.securityInfoWarningPopup(errorMessage: errorMessage, warningType: warningType)
                router.presentViewController(controller: popup)
            }
        }



// MARK: - Presenter
extension SecurityInfoViewController {
    private func questionWasSuccessfullyUpdated(type: SecurityScreenEntryType) {
        RouterVC().popViewController()
        let message = successMessage(type: type)
        SnackbarManager.shared.show(type: .nonCritical, message: message)
        //dismiss(animated: true)
    }
    
    private func successMessage(type: SecurityScreenEntryType) -> String {
        switch type {
        case .securityQuestion:
            return TextConstants.userProfileSetSecretQuestionSuccess
        case .recoveryMail:
            return localized(.setRecoveryMailSuccess)
        case .all:
            return localized(.setRecoveryMailSecurityQuestionSuccess)
        }
    }
    
    private func handleServerErrors(_ error: SetSecretQuestionErrors) {
        captchaView.updateCaptcha()
        captchaView.captchaAnswerTextField.text = ""
        let errorText = error.localizedDescription
        
        switch error {
        case .invalidCaptcha:
            captchaView.showErrorAnimated(text: errorText)
            captchaView.captchaAnswerTextField.becomeFirstResponder()
        case .invalidId:
            secretAnswerView.showSubtitleTextAnimated(text: errorText)
        case .invalidAnswer:
            secretAnswerView.showSubtitleTextAnimated(text: errorText)
        case .unknown:
            UIApplication.showErrorAlert(message: errorText)
        }
    }
}

// MARK: - Interactor
extension SecurityInfoViewController {
    private func getQuestions(handler: @escaping ([SecretQuestionsResponse]) -> Void) {
        if questions.hasItems {
            handler(questions)
            
        } else {
            accountService.getListOfSecretQuestions { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let questions):
                    self.questions = questions
                    handler(questions)
                case .failed(let error):
                    self.showErrorPopUp(error: error)
                    self.hideSpinnerIncludeNavigationBar()
                }
            }
        }
    }
    
    private func updateSecurityQuestion(questions: ([SecretQuestionsResponse]), completion: @escaping () -> ()) {
        guard let captchaAnswer = captchaView.captchaAnswerTextField.text,
              let questionId = answer.questionId,
              let securityQuestionAnswer = answer.questionAnswer else {
                  assertionFailure("all fields should not be nil")
                  hideSpinnerIncludeNavigationBar()
                  return
              }
        
        accountService.updateSecurityQuestion(questionId: questionId,
                                              securityQuestionAnswer: securityQuestionAnswer,
                                              captchaId: captchaView.currentCaptchaUUID,
                                              captchaAnswer: captchaAnswer) { [weak self] result in
            
            guard let self = self else { return }
            self.hideSpinnerIncludeNavigationBar()

            switch result {
            case .success:
                self.securityQuestionOperation = (true, nil)
                completion()
            case .failure(let error):
                self.securityQuestionOperation = (false, error)
                completion()
            }
        }
    }
    
    private func setRecoveryEmail(with recoveryEmail: String, completion: @escaping () -> ()) {
        let parameters = UserRecoveryEmailParameters(email: recoveryEmail)
        AccountService().updateUserRecoveryEmail(parameters: parameters,
                                                 success: { [weak self] response in
            self?.hideSpinnerIncludeNavigationBar()
            self?.recoveryEmailOperation = (true, nil)
            completion()
        }, fail: { [weak self] error in
            self?.hideSpinnerIncludeNavigationBar()
            self?.recoveryEmailOperation = (false, error.errorDescription)
            completion()
        })
    }
}

// MARK: - SecurityQuestionViewDelegate
extension SecurityInfoViewController: SecurityQuestionViewDelegate {
    func selectSecurityQuestionTapped() {
        getQuestions { [weak self] questions in
            guard let self = self else { return }
            let controller = SelectQuestionViewController.createController(questions: questions, delegate: self)
            self.present(controller, animated: true)
        }
    }
}

// MARK: - SelectQuestionViewControllerDelegate
extension SecurityInfoViewController: SelectQuestionViewControllerDelegate {
    func didSelectQuestion(question: SecretQuestionsResponse?) {
        
        guard let question = question else {
            assertionFailure()
            return
        }
        
        answer.questionId = question.id
        answer.question = question.text
        securityQuestionView.setQuestion(question: question.text)
        secretAnswerView.textField.text = ""
        secretAnswerView.textField.quickDismissPlaceholder = TextConstants.userProfileSecretQuestionAnswerPlaseholder
        secretAnswerView.textField.placeholderColor = ColorConstants.placeholderGrayColor
        checkButtonStatus()
    }
    
    private func showErrorPopUp(error: Error) {
        if error.errorCode == 204 {
            UIApplication.showErrorAlert(message: TextConstants.userProfileNoSecretQuestion)
        }
    }
}
