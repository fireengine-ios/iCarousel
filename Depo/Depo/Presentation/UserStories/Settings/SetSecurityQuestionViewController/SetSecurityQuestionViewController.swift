//
//  SetSecurityQuestionViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

struct SecretQuestionWithAnswer {
    var questionId: Int?
    var question: String?
    var questionAnswer: String?
}

protocol SetSecurityQuestionViewControllerDelegate {
    func didCloseSetSecurityQuestionViewController(with selectedQuestion: SecretQuestionWithAnswer)
}

final class SetSecurityQuestionViewController: UIViewController, KeyboardHandler, NibInit {
    
    private let accountService = AccountService()
    private lazy var answer = SecretQuestionWithAnswer()
    var delegate: SetSecurityQuestionViewControllerDelegate?
    
    @IBOutlet private weak var saveButton: RoundedButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.setTitle(TextConstants.fileInfoSave, for: .normal)
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!  {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView!  {
        willSet {
            newValue.spacing = 18
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            newValue.addArrangedSubview(securityQuestionView)
            newValue.addArrangedSubview(secretAnswerView)
            newValue.addArrangedSubview(captchaView)
        }
    }

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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    private func initSetup() {
        title = TextConstants.userProfileSecretQuestion
        securityQuestionView.delegate = self
        secretAnswerView.answerTextField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        captchaView.captchaAnswerTextField.addTarget(self, action: #selector(checkButtonStatus), for: .editingChanged)
        addTapGestureToHideKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkButtonStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        
        answer.questionAnswer = secretAnswerView.answerTextField.text
        captchaView.hideErrorAnimated()
        secretAnswerView.hideErrorAnimated()
        
        guard
            let captchaAnswer = captchaView.captchaAnswerTextField.text,
            let questionId = answer.questionId,
            let securityQuestionAnswer = answer.questionAnswer
        else {
            assertionFailure("all fields should not be nil")
            return
        }
        
        accountService.updateSecurityQuestion(questionId: questionId,
                                              securityQuestionAnswer: securityQuestionAnswer,
                                              captchaId: captchaView.currentCaptchaUUID,
                                              captchaAnswer: captchaAnswer) { result in
                                                
                                                switch result {
                                                case .success:
                                                    self.questionWasSuccessfullyUpdated()
                                                case .failure(let error):
                                                    self.handleServerErrors(error)                                                }
        }
    }
    
    func configureWith(selectedQuestion: SecretQuestionsResponse?, delegate: SetSecurityQuestionViewControllerDelegate) {
        self.delegate = delegate
        answer.questionId = selectedQuestion?.id
        setupDescriptionLabel(selectedQuestion: selectedQuestion?.text)
    }
    
    private func setupDescriptionLabel(selectedQuestion: String?) {
        guard let question = selectedQuestion else {
            return
        }
        
        secretAnswerView.answerTextField.quickDismissPlaceholder = "* * * * * * * * *"
        secretAnswerView.answerTextField.placeholderColor = UIColor.black
        securityQuestionView.setQuestion(question: question)
    }
    
    private func questionWasSuccessfullyUpdated() {
        delegate?.didCloseSetSecurityQuestionViewController(with: answer)
        self.navigationController?.popViewController(animated: false)
    }
       
    private func handleServerErrors(_ error: SetSecretQuestionErrors) {
        
        captchaView.updateCaptcha()
        captchaView.captchaAnswerTextField.text = ""
        
        let errorText = error.localizedDescription
        
        switch error {
        case .invalidCaptcha:
            captchaView.showErrorAnimated(text: errorText)
            captchaView.updateCaptcha()
            captchaView.captchaAnswerTextField.becomeFirstResponder()
        case .invalidId:
            secretAnswerView.showErrorAnimated(text: errorText)
        case .invalidAnswer:
            secretAnswerView.showErrorAnimated(text: errorText)
        case .unknown:
            UIApplication.showErrorAlert(message: errorText)
        }

    }
    
    @objc private func checkButtonStatus() {
    
        guard let captchaText = captchaView.captchaAnswerTextField.text,
            let answerText = secretAnswerView.answerTextField.text,
            answer.questionId != nil
        else {
            saveButton.isEnabled = false
            return
        }
        
        if captchaText.isEmpty || answerText.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}

extension SetSecurityQuestionViewController: SelectQuestionViewControllerDelegate {
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

extension SetSecurityQuestionViewController: SecurityQuestionViewDelegate {
    func selectSecurityQuestionTapped() {
            accountService.getListOfSecretQuestions { [weak self] response in
                guard let self = self else {
                    assertionFailure()
                    return
                }
                
                switch response {
                case .success( let questions):
                    let controller = SelectQuestionViewController.createController(questions: questions, delegate: self)
                    self.present(controller, animated: true)
                case .failed(let error):
                    self.showErrorPopUp(error: error)
                }
            }
    }
}
