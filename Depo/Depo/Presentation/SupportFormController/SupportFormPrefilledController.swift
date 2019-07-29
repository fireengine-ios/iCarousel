import UIKit

struct SupportFormConfiguration {
    let name: String?
    let surname: String?
    let phone: String?
    let email: String?
}

final class SupportFormPrefilledController: ViewController, KeyboardHandler {
    
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
            newValue.addArrangedSubview(descriptionView)
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
    
    private let nameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileName
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourName
        newValue.textField.placeholder = TextConstants.enterYourName
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    private let surnameView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileSurname
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourSurname
        newValue.textField.placeholder = TextConstants.enterYourSurname
        newValue.textField.autocorrectionType = .no
        return newValue
    }()
    
    private let emailView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
        /// not set bcz of showEmptyCredentialsPopup
        //newValue.subtitleLabel.text
        newValue.textField.placeholder = TextConstants.enterYourEmailAddress
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocorrectionType = .no
        newValue.textField.autocapitalizationType = .none
        
        newValue.textField.isUserInteractionEnabled = false
        // TODO: 25
        newValue.textField.textColor = UIColor.black.withAlphaComponent(0.25)
        return newValue
    }()
    
    private let phoneView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.profilePhoneNumberTitle
        newValue.subtitleLabel.text = ""
        newValue.textField.placeholder = TextConstants.profilePhoneNumberPlaceholder
        newValue.textField.autocorrectionType = .no
        
        newValue.textField.isUserInteractionEnabled = false
        // TODO: 25
        newValue.textField.textColor = UIColor.black.withAlphaComponent(0.25)
        return newValue
    }()
    
    private let subjectView: ProfileTextPickerView = {
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
        // TODO: add new
        return newValue
    }()
    
    private let descriptionView: UILabel = {
        let newValue = UILabel()
        newValue.numberOfLines = 0
        newValue.textColor = ColorConstants.textGrayColor
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        // TODO: localize
        newValue.text = "We support you in Turkish, English, Arabic languages, so please write your comment in one of these languages"
        return newValue
    }()
    
    private let problemView: ProfileTextViewEnterView = {
        let newValue = ProfileTextViewEnterView()
        newValue.titleLabel.text = TextConstants.yourProblem
        newValue.subtitleLabel.text = TextConstants.pleaseEnterYourProblemShortly
        return newValue
    }()
    
    var config: SupportFormConfiguration?
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarWithGradientStyle()
        
        addTapGestureToHideKeyboard()
        setupTextFields()
        setupConfigIfNeed()
    }
    
    private func setupTextFields() {
        nameView.textField.delegate = self
        surnameView.textField.delegate = self
        emailView.textField.delegate = self
        subjectView.textField.delegate = self
        
        phoneView.textField.delegate = self
        
        subjectView.responderOnNext = problemView.textView
    }
    
    func setupConfigIfNeed() {
        guard let config = config else {
            return
        }
        
        nameView.textField.text = config.name
        surnameView.textField.text = config.surname
        emailView.textField.text = config.email
        phoneView.textField.text = config.phone
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
            let fullPhoneNumber = phoneView.textField.text,
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
        
        if email.isEmpty && fullPhoneNumber.isEmpty {
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
            if fullPhoneNumber.isEmpty {
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
            subjectView.textField.becomeFirstResponder()
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
}

extension SupportFormPrefilledController: UITextFieldDelegate {
    
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
            
        case phoneView.textField:
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
            subjectView.textField.becomeFirstResponder()
            
        /// emailView, phoneView are disabled
            
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
