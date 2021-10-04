//
//  ValidateSecurityQuestionViewController.swift
//  Depo
//
//  Created by Hady on 9/23/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ValidateSecurityQuestionViewController: BaseViewController, KeyboardHandler {
    private let resetPasswordService: ResetPasswordService
    private let accountService: AccountService
    private let questionId: Int
    private let analyticsService = AnalyticsService()

    init(resetPasswordService: ResetPasswordService,
         accountService: AccountService = AccountService(),
         questionId: Int) {
        self.resetPasswordService = resetPasswordService
        self.accountService = accountService
        self.questionId = questionId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 18
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true

            newValue.addArrangedSubview(questionView)
            newValue.addArrangedSubview(answerView)
        }
    }
    
    @IBOutlet private weak var continueButton: WhiteButtonWithRoundedCorner! {
        willSet {
            newValue.setTitle(localized(.resetPasswordContinueButton), for: .normal)
            newValue.setTitleColor(ColorConstants.whiteColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)
            newValue.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)
        }
    }

    private let questionView: SecurityQuestionView = {
        let view = SecurityQuestionView.initFromNib()
        view.showsArrowButton = false
        return view
    }()

    private let answerView: SecretAnswerView = {
        let view = SecretAnswerView.initFromNib()
        view.answerTextField.returnKeyType = .done
        view.answerTextField.enablesReturnKeyAutomatically = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized(.resetPasswordTitle)

        populateQuestion()

        continueButton.isEnabled = false
        answerView.answerTextField.addTarget(self, action: #selector(answerTextChanged), for: .editingChanged)
        answerView.answerTextField.delegate = self

        addTapGestureToHideKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen()
    }

    @objc private func answerTextChanged() {
        let isEmpty = answerView.answerTextField.text?.isEmpty ?? true
        continueButton.isEnabled = !isEmpty
    }

    @IBAction private func continueTapped() {
        guard let answer = answerView.answerTextField.text else { return }

        showSpinnerIncludeNavigationBar()
        resetPasswordService.delegate = self
        resetPasswordService.validateSecurityQuestion(id: questionId, answer: answer)
    }
}

extension ValidateSecurityQuestionViewController: ResetPasswordServiceDelegate {
    func resetPasswordServiceVerifiedSecurityQuestion(_ service: ResetPasswordService) {
        hideSpinnerIncludeNavigationBar()

        guard let navigationController = self.navigationController else { return }
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast() // Self
        viewControllers.removeLast() // IdentityVerificationViewController
        viewControllers.append(ResetPasswordViewController(resetPasswordService: resetPasswordService))
        navigationController.setViewControllers(viewControllers, animated: true)

        trackContinueEvent(error: nil)
    }

    func resetPasswordService(_ service: ResetPasswordService, receivedError error: Error) {
        hideSpinnerIncludeNavigationBar()
        UIApplication.showErrorAlert(message: error.localizedDescription)

        trackContinueEvent(error: error)
    }
}

extension ValidateSecurityQuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        continueTapped()
        return true
    }
}

private extension ValidateSecurityQuestionViewController {
    func populateQuestion() {
        showSpinner()
        getQuestionTitle { [weak self] title in
            self?.hideSpinner()
            if let title = title {
                self?.questionView.setQuestion(question: title)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    func getQuestionTitle(completion: @escaping (String?) -> Void) {
        accountService.getListOfSecretQuestions { [questionId] result in
            switch result {
            case let .success(questions):
                let question = questions.first { $0.id == questionId }
                completion(question?.text)
            case let .failed(error):
                debugLog("Failed to get question list. \(error)")
                completion(nil)
            }
        }
    }
}

private extension ValidateSecurityQuestionViewController {
    func trackScreen() {
        analyticsService.logScreen(screen: .validateSecurityQuestion)
    }

    func trackContinueEvent(error: Error?) {
        analyticsService.trackCustomGAEvent(
            eventCategory: .functions,
            eventActions: .securityQuestion,
            eventLabel: .result(error)
        )
    }
}
