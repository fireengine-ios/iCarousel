import UIKit

final class SupportFormController: ViewController, KeyboardHandler {
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 11
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            let fullnameStackView = UIStackView(arrangedSubviews: [nameView, surnameView])
            fullnameStackView.spacing = 20
            fullnameStackView.axis = .horizontal
            fullnameStackView.alignment = .fill
            fullnameStackView.distribution = .fillEqually
            fullnameStackView.backgroundColor = .white
            fullnameStackView.isOpaque = true
            
            newValue.addArrangedSubview(fullnameStackView)
            newValue.addArrangedSubview(emailView)
            newValue.addArrangedSubview(phoneView)
            newValue.addArrangedSubview(subjectView)
            newValue.addArrangedSubview(problemView)
        }
    }
    
    @IBOutlet private weak var sendButton: RoundedInsetsButton! {
        willSet {
            /// Custom type in IB
            newValue.isExclusiveTouch = true
            newValue.setTitle(TextConstants.feedbackViewSendButton, for: .normal)
            newValue.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish.darker(by: 30), for: .highlighted)
            
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    let nameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileName
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourName
        newValue.textField.placeholder = TextConstants.enterYourName
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let surnameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileSurname
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSurname
        newValue.textField.placeholder = TextConstants.enterYourSurname
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let emailView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
        /// not set bcz of showEmptyCredentialsPopup
        //newValue.subtitleLabel.text
        newValue.textField.placeholder = TextConstants.enterYourEmailAddress
        newValue.textField.keyboardType = .emailAddress
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()
    
    let subjectView: ProfileTextPickerView = {
        let newValue = ProfileTextPickerView()
        newValue.titleLabel.text = TextConstants.subject
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSubject
        newValue.textField.placeholder = TextConstants.pleaseChooseSubject
        newValue.models = [TextConstants.supportFormSubject1,
                           TextConstants.supportFormSubject2,
                           TextConstants.supportFormSubject3,
                           TextConstants.supportFormSubject4,
                           TextConstants.supportFormSubject5,
                           TextConstants.supportFormSubject6,
                           TextConstants.supportFormSubject7]
        return newValue
    }()
    
    let problemView: ProfileTextViewEnterView = {
        let newValue = ProfileTextViewEnterView()
        newValue.titleLabel.text = TextConstants.yourProblem
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourProblemShortly
        return newValue
    }()
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarWithGradientStyle()

        addTapGestureToHideKeyboard()
        setupTextFields()
    }
    
    private func setupTextFields() {
        nameView.textField.delegate = self
        surnameView.textField.delegate = self
        emailView.textField.delegate = self
        subjectView.textField.delegate = self
        
        phoneView.numberTextField.delegate = self
        phoneView.codeTextField.delegate = self
        
        phoneView.responderOnNext = subjectView.textField
        subjectView.responderOnNext = problemView.textView
    }
    
    @IBAction private func onSendButton(_ sender: UIButton) {
        openEmail()
    }
    
    private func openEmail() {
        
        guard Mail.canSendEmail() else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackEmailError)
            return
        }
        
        guard
            let name = nameView.textField.text,
            let surname = surnameView.textField.text,
            let email = emailView.textField.text,
            let phoneCode = phoneView.codeTextField.text,
            let phoneNumber = phoneView.numberTextField.text,
            let subject = subjectView.textField.text,
            let problem = problemView.textView.text
        else {
            assertionFailure("all fields should not be nil")
            return
        }

        if name.isEmpty {
            actionOnError(.emptyName)
        } else if surname.isEmpty {
            actionOnError(.emptySurname)
        } else if email.isEmpty && phoneNumber.isEmpty {
            actionOnError(.emptyCredentials)
        } else if !email.isEmpty && !Validator.isValid(email: email) {
            actionOnError(.invalidEmail)
        } else if subject.isEmpty {
            actionOnError(.emptySubject)
            
        /// bcz of placeholder use isTextEmpty
        } else if problemView.isTextEmpty {
            actionOnError(.emptyProblem)
        } else {
            
            let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
            let emailBody = problem + "\n\n" +
                String(format: TextConstants.supportFormEmailBody,
                       name,
                       surname,
                       email,
                       "\(phoneCode)\(phoneNumber)",
                        versionString,
                        CoreTelephonyService().operatorName() ?? "",
                        UIDevice.current.modelName,
                        UIDevice.current.systemVersion,
                        Device.locale,
                        ReachabilityService().isReachableViaWiFi ? "WIFI" : "WWAN")
            
            Mail.shared().sendEmail(emailBody: emailBody,
                                    subject: subject,
                                    emails: [TextConstants.feedbackEmail], success: {
                                        RouterVC().popViewController()
            }, fail: { error in
                UIApplication.showErrorAlert(message: error?.description ?? TextConstants.feedbackEmailError)
            })
        }
    }
    
    private func actionOnError(_ error: SupportFormErrors) {
        switch error {
        case .emptyName:
            nameView.showSubtitleAnimated()
            nameView.textField.becomeFirstResponder()
            scrollToView(nameView)
            
        case .emptySurname:
            surnameView.showSubtitleAnimated()
            surnameView.textField.becomeFirstResponder()
            scrollToView(surnameView)
            
        case .emptyCredentials:
            emailView.textField.becomeFirstResponder()
            scrollToView(emailView)
            showEmptyCredentialsPopup()
            
        case .emptySubject:
            subjectView.showSubtitleAnimated()
            subjectView.textField.becomeFirstResponder()
            scrollToView(subjectView)
            
        case .emptyProblem:
            problemView.showSubtitleAnimated()
            problemView.textView.becomeFirstResponder()
            scrollToView(problemView)
            
        case .invalidEmail:
            emailView.showSubtitleTextAnimated(text: TextConstants.EMAIL_IS_INVALID)
            emailView.textField.becomeFirstResponder()
            scrollToView(emailView)
        }
    }
    
    private func showEmptyCredentialsPopup() {
        UIApplication.showErrorAlert(message: TextConstants.pleaseEnterMsisdnOrEmail)
    }
    
    private func scrollToView(_ view: UIView) {
        let rect = scrollView.convert(view.frame, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}

extension SupportFormController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameView.textField:
            nameView.hideSubtitleAnimated()
            
        case surnameView.textField:
            surnameView.hideSubtitleAnimated()
            
        case emailView.textField:
            emailView.hideSubtitleAnimated()
            
        case subjectView.textField:
            subjectView.hideSubtitleAnimated()

        case phoneView.numberTextField, phoneView.codeTextField:
            phoneView.hideSubtitleAnimated()
            
        default:
            assertionFailure()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameView.textField:
            surnameView.textField.becomeFirstResponder()
            
        case surnameView.textField:
            emailView.textField.becomeFirstResponder()
            
        case emailView.textField:
            phoneView.codeTextField.becomeFirstResponder()
        
        /// setup in view.
        /// only for simulator.
        case phoneView.codeTextField:
            phoneView.numberTextField.becomeFirstResponder()
        
        /// only for simulator.
        /// setup by responderOnNext:
        case phoneView.numberTextField:
            subjectView.textField.becomeFirstResponder()
            
        /// only for simulator.
        /// setup by responderOnNext:
        case subjectView.textField:
            problemView.textView.becomeFirstResponder()
            
        default:
            assertionFailure()
        }
        
        return true
    }
}

enum SupportFormErrors {
    case emptyName
    case emptySurname
    case emptyCredentials
    case emptySubject
    case emptyProblem
    case invalidEmail
}
