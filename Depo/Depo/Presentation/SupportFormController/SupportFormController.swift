import UIKit

final class SupportFormController: ViewController, KeyboardHandler {
    
    static func with(screenType: SupportFormScreenType) -> SupportFormController {
        let controller = SupportFormController()
        controller.screenType = screenType
        return controller
    }
    
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
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourName
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let surnameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileSurname
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSurname
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourSurname
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    let emailView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
        /// not set bcz of showEmptyCredentialsPopup
        //newValue.subtitleLabel.text
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocorrectionType = .no
        newValue.textField.autocapitalizationType = .none
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()
    
    let subjectView: ProfileTextPickerView = {
        let newValue = ProfileTextPickerView()
        newValue.titleLabel.text = TextConstants.subject
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSubject

        newValue.textField.quickDismissPlaceholder = TextConstants.pleaseChooseSubject
        newValue.models = [TextConstants.onLoginSupportFormSubject1,
                           TextConstants.onLoginSupportFormSubject2,
                           TextConstants.onLoginSupportFormSubject3,
                           TextConstants.onLoginSupportFormSubject4,
                           TextConstants.onLoginSupportFormSubject5,
                           TextConstants.onLoginSupportFormSubject6,
                           TextConstants.onLoginSupportFormSubject7]
        return newValue
    }()
    
    let problemView: ProfileTextViewEnterView = {
        let newValue = ProfileTextViewEnterView()
        newValue.titleLabel.text = TextConstants.yourProblem
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourProblemShortly
        return newValue
    }()
    
    private var subjects = [SupportFormSubjectTypeProtocol]()
    private var screenType: SupportFormScreenType = .login
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    // MARK: -
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjects = screenType.subjects
        subjectView.models = subjects.map { $0.localizedSubject }
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
        
        var problems = [SupportFormErrors]()

        if name.isEmpty {
            problems.append(.emptyName)
        }
        
        if surname.isEmpty {
            problems.append(.emptySurname)
        }
        
        if email.isEmpty && phoneNumber.isEmpty {
            problems.append(.emptyCredentials)
        }
        
        if !email.isEmpty && !Validator.isValid(email: email) {
            problems.append(.invalidEmail)
        }
        
        if subject.isEmpty {
            problems.append(.emptySubject)
        }
        
        /// bcz of placeholder use isTextEmpty
        if problemView.isTextEmpty {
            problems.append(.emptyProblem)
        }
        
        
        if problems.isEmpty {
            let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
            let fullPhoneNumber = "\(phoneCode)\(phoneNumber)"
            
            let emailBody = problem + "\n\n" +
                String(format: TextConstants.supportFormEmailBody,
                       name,
                       surname,
                       email,
                       fullPhoneNumber,
                        versionString,
                        CoreTelephonyService().operatorName() ?? "",
                        UIDevice.current.modelName,
                        UIDevice.current.systemVersion,
                        Device.locale,
                        ReachabilityService.shared.isReachableViaWiFi ? "WIFI" : "WWAN")
            
            let emailSubject: String
            if phoneNumber.isEmpty {
                emailSubject = subject
            } else {
                emailSubject = "\(fullPhoneNumber) - \(subject)"
            }
            
            Mail.shared().sendEmail(emailBody: emailBody,
                                    subject: emailSubject,
                                    emails: [TextConstants.NotLocalized.feedbackEmail], success: {
                                        RouterVC().popViewController()
            }, fail: { error in
                UIApplication.showErrorAlert(message: error?.description ?? TextConstants.feedbackEmailError)
            })
        } else {
            problems = problems.sorted(by: { $0.rawValue < $1.rawValue })
            
            problems.forEach {
                showError($0)
            }
            
            actionOnTopError(problems.first)
        }
    }
    
    private func showError(_ error: SupportFormErrors) {
        switch error {
        case .emptyName:
            nameView.showSubtitleAnimated()
            
        case .emptySurname:
            surnameView.showSubtitleAnimated()
            
        case .emptyCredentials:
            showEmptyCredentialsPopup()
            
        case .emptySubject:
            subjectView.showSubtitleAnimated()
            
        case .emptyProblem:
            problemView.showSubtitleAnimated()
            
        case .invalidEmail:
            emailView.showSubtitleTextAnimated(text: TextConstants.EMAIL_IS_INVALID)
        }
    }
    
    private func actionOnTopError(_ error: SupportFormErrors?) {
        guard let error = error else {
            return
        }
        
        switch error {
        case .emptyName:
            nameView.textField.becomeFirstResponder()
            scrollToView(nameView)
            
        case .emptySurname:
            surnameView.textField.becomeFirstResponder()
            scrollToView(surnameView)
            
        case .emptyCredentials:
            emailView.textField.becomeFirstResponder()
            scrollToView(emailView)
            
        case .emptySubject:
            scrollToView(subjectView)
            
        case .emptyProblem:
            problemView.textView.becomeFirstResponder()
            scrollToView(problemView)
            
        case .invalidEmail:
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
    
    private func trackSubjectSelection() {
        let subject = subjects[subjectView.selectedIndex]
        analyticsService.trackSupportEvent(screenType: screenType, subject: subject, isSupportForm: true)
    }
}

// MARK: - UITextFieldDelegate

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
            trackSubjectSelection()

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
            trackSubjectSelection()
            
        default:
            assertionFailure()
        }
        
        return true
    }
}

enum SupportFormErrors: Int {
    case emptyName
    case emptySurname
    case emptyCredentials
    case emptySubject
    case emptyProblem
    case invalidEmail
}
