//
//  SecurityInfoPopup.swift
//  Lifebox
//
//  Created by Burak Donat on 12.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import Typist

final class SecurityInfoPopup: BasePopUpController, NibInit, KeyboardHandler {

    //MARK: -IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.textGrayColor
            newValue.text = localized(.securityPopupHeader)
        }
    }
    
    @IBOutlet private weak var bottomLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 15)
            newValue.textColor = ColorConstants.textGrayColor
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
    
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.isUserInteractionEnabled = false
            newValue.setTitleColor(AppColor.marineTwoAndTealish.color, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.marineTwoAndTealish.color?.cgColor
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
    
    private let secretAnswerView: SecretAnswerView = {
        let view = SecretAnswerView.initFromNib()
        return view
    }()
    
    private let captchaView: CaptchaView = {
        let view = CaptchaView()
        view.updateCaptcha()
        return view
    }()
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        initSetup()
        setupKeyboard()
    }
    
    //MARK: -Helpers
    private func initSetup() {
        securityQuestionView.delegate = self
        secretAnswerView.answerTextField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        captchaView.captchaAnswerTextField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        recoveryEmailView.textField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        addTapGestureToHideKeyboard()
    }
    
    private func setSaveButton(isActive: Bool) {
        saveButton.setTitleColor(isActive ? UIColor.white : AppColor.marineTwoAndTealish.color, for: .normal)
        saveButton.isUserInteractionEnabled = isActive
        saveButton.backgroundColor = isActive ? AppColor.marineTwoAndTealish.color : UIColor.clear
    }
    
    @objc private func checkButtonStatus() {
        guard let secretAnswer = secretAnswerView.answerTextField.text,
              let recoveryEmail = recoveryEmailView.textField.text,
              let captchaAnswer = captchaView.captchaAnswerTextField.text else {
                  setSaveButton(isActive: false)
                  return
              }
        
        let shouldButtonActive = (!secretAnswer.isEmpty && !captchaAnswer.isEmpty) || !recoveryEmail.isEmpty
        setSaveButton(isActive: shouldButtonActive)
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                self?.scrollViewBottomConstraint.constant = options.endFrame.height
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
        answer.questionAnswer = secretAnswerView.answerTextField.text
        captchaView.hideErrorAnimated()
        secretAnswerView.hideErrorAnimated()
        securityQuestionOperation = nil
        recoveryEmailOperation = nil
        
        guard let secretAnswer = secretAnswerView.answerTextField.text,
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
    }
    
    private func handleApiCalls() {
        if securityQuestionOperation == nil && recoveryEmailOperation != nil {
            recoveryEmailOperation?.isSuccess == true ? dismiss(animated: true)
            : UIApplication.showErrorAlert(message: recoveryEmailOperation?.errorMessage ?? "")
            return
        }
        
        if securityQuestionOperation != nil && recoveryEmailOperation == nil {
            securityQuestionOperation?.isSuccess == true ? questionWasSuccessfullyUpdated()
            : handleServerErrors(securityQuestionOperation?.errorMessage ?? .unknown)
            return
        }
        
        if securityQuestionOperation != nil && recoveryEmailOperation != nil {
            if securityQuestionOperation?.isSuccess == true && recoveryEmailOperation?.isSuccess == true {
                questionWasSuccessfullyUpdated()
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
        dismiss(animated: true) {
            let router = RouterVC()
            let popup = router.securityInfoWarningPopup(errorMessage: errorMessage, warningType: warningType)
            router.presentViewController(controller: popup)
        }
    }
}

// MARK: - Presenter
extension SecurityInfoPopup {
    private func questionWasSuccessfullyUpdated() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.userProfileSetSecretQuestionSuccess)
        dismiss(animated: true)
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
            secretAnswerView.showErrorAnimated(text: errorText)
        case .invalidAnswer:
            secretAnswerView.showErrorAnimated(text: errorText)
        case .unknown:
            UIApplication.showErrorAlert(message: errorText)
        }
    }
}

// MARK: - Interactor
extension SecurityInfoPopup {
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
            completion()
            
            switch result {
            case .success:
                self.securityQuestionOperation = (true, nil)
            case .failure(let error):
                self.securityQuestionOperation = (false, error)
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
extension SecurityInfoPopup: SecurityQuestionViewDelegate {
    func selectSecurityQuestionTapped() {
        getQuestions { [weak self] questions in
            guard let self = self else { return }
            let controller = SelectQuestionViewController.createController(questions: questions, delegate: self)
            self.present(controller, animated: true)
        }
    }
}

// MARK: - SelectQuestionViewControllerDelegate
extension SecurityInfoPopup: SelectQuestionViewControllerDelegate {
    func didSelectQuestion(question: SecretQuestionsResponse?) {
        
        guard let question = question else {
            assertionFailure()
            return
        }
        
        answer.questionId = question.id
        answer.question = question.text
        securityQuestionView.setQuestion(question: question.text)
        secretAnswerView.answerTextField.text = ""
        secretAnswerView.answerTextField.quickDismissPlaceholder = TextConstants.userProfileSecretQuestionAnswerPlaseholder
        secretAnswerView.answerTextField.placeholderColor = ColorConstants.placeholderGrayColor
        checkButtonStatus()
    }
    
    private func showErrorPopUp(error: Error) {
        if error.errorCode == 204 {
            UIApplication.showErrorAlert(message: TextConstants.userProfileNoSecretQuestion)
        }
    }
}
