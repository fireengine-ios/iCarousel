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

final class SetSecurityQuestionViewController: UIViewController, KeyboardHandler, NibInit, ControlTabBarProtocol {
    
    private let accountService = AccountService()
    private lazy var answer = SecretQuestionWithAnswer()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var questions = [SecretQuestionsResponse]()
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
    
    // MARK: - Init
    
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
        
        analyticsService.logScreen(screen: .securityQuestion)
        analyticsService.trackDimentionsEveryClickGA(screen: .securityQuestion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkButtonStatus()
        navigationBarWithGradientStyle()
        hideTabBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        showSpinnerIncludeNavigationBar()
        answer.questionAnswer = secretAnswerView.answerTextField.text
        captchaView.hideErrorAnimated()
        secretAnswerView.hideErrorAnimated()
        
        getQuestions { [weak self] questions in
            self?.updateSecurityQuestion(questions: questions)
        }
    }
    
    func configureWith(selectedQuestion: SecretQuestionsResponse?,
                       delegate: SetSecurityQuestionViewControllerDelegate?) {
        self.delegate = delegate
        answer.questionId = selectedQuestion?.id
        answer.question = selectedQuestion?.text
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
    
    private func getQuestions(handler: @escaping ([SecretQuestionsResponse]) -> Void) {
        /// can be added lock for synchronization if there will be several requests
        
        if questions.hasItems {
            handler(questions)
            
        } else {
            accountService.getListOfSecretQuestions { [weak self] response in
                guard let self = self else {
                    return
                }
                
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
    
    private func updateSecurityQuestion(questions: ([SecretQuestionsResponse])) {
        
        guard
            let captchaAnswer = captchaView.captchaAnswerTextField.text,
            let questionId = answer.questionId,
            let questionIndex = questions.firstIndex(where: { $0.id == questionId }),
            let securityQuestionAnswer = answer.questionAnswer
        else {
            assertionFailure("all fields should not be nil")
            hideSpinnerIncludeNavigationBar()
            return
        }
           
        accountService.updateSecurityQuestion(questionId: questionId,
                                              securityQuestionAnswer: securityQuestionAnswer,
                                              captchaId: captchaView.currentCaptchaUUID,
                                              captchaAnswer: captchaAnswer) { [weak self] result in
                                                
                                                guard let self = self else {
                                                    return
                                                }
                                                self.hideSpinnerIncludeNavigationBar()
                                                
                                                switch result {
                                                case .success:
                                                    self.questionWasSuccessfullyUpdated()
                                                    self.analyticsService.trackCustomGAEvent(eventCategory: .securityQuestion,
                                                                                             eventActions: .saveSecurityQuestion(questionIndex + 1),
                                                                                             eventLabel: .success)
                                                case .failure(let error):
                                                    self.handleServerErrors(error)
                                                    self.analyticsService.trackCustomGAEvent(eventCategory: .securityQuestion,
                                                                                             eventActions: .saveSecurityQuestion(questionIndex + 1),
                                                                                             eventLabel: .failure,
                                                                                             errorType: error.gaErrorType)
                                                }
        }
    }
}

// MARK: - SelectQuestionViewControllerDelegate
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

// MARK: - SecurityQuestionViewDelegate
extension SetSecurityQuestionViewController: SecurityQuestionViewDelegate {
    
    func selectSecurityQuestionTapped() {
        
        getQuestions { [weak self] questions in
            guard let self = self else {
                return
            }
            let controller = SelectQuestionViewController.createController(questions: questions, delegate: self)
            self.present(controller, animated: true)
        }
    }
    
}
