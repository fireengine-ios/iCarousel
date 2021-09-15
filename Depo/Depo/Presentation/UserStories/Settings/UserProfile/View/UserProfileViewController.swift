import UIKit

final class UserProfileViewController: ViewController, KeyboardHandler {
    
    var output: UserProfileViewOutput!
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 24
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

            let arrangedSubviews = [
                fullnameStackView,
                emailView,
                phoneView,
                recoveryEmailView,
                birthdayDetailView,
                addressView,
                changePasswordButton,
                changeSecurityQuestionButton,
            ]
            arrangedSubviews.forEach(newValue.addArrangedSubview(_:))
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
    
    let emailView: ProfileEmailFieldView = {
        let newValue = ProfileEmailFieldView()
        newValue.titleLabel.text = TextConstants.userProfileEmailSubTitle
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()

    let recoveryEmailView: ProfileEmailFieldView = {
        let newValue = ProfileEmailFieldView()
        newValue.titleLabel.text = localized(.profileRecoveryMail)
        newValue.subtitleLabel.text = localized(.profileRecoveryMailDescription)
        newValue.textField.quickDismissPlaceholder = localized(.profileRecoveryMailHint)
        return newValue
    }()
    
    private let birthdayDetailView: ProfileBirthdayFieldView = {
        let newValue = ProfileBirthdayFieldView()
        newValue.title = TextConstants.userProfileBirthday
        return newValue
    }()
    
    let addressView: ProfileTextEnterView = {
        let newValue = ProfileTextEnterView()
        newValue.titleLabel.text = TextConstants.profileDetailAddressTitle
        newValue.subtitleLabel.text = TextConstants.profileDetailAddressSubtitle
        newValue.textField.quickDismissPlaceholder = TextConstants.profileDetailAddressPlaceholder
        newValue.textField.autocorrectionType = .no
        newValue.textField.returnKeyType = .done
        return newValue
    }()
    
    lazy var changePasswordButton: UIButton = {
        let newValue = UIButton(type: .custom)
        set(title: TextConstants.userProfileChangePassword, for: newValue)
        newValue.addTarget(self, action: #selector(onChangePassword), for: .touchUpInside)
        newValue.contentHorizontalAlignment = .left
        return newValue
    }()
    
    lazy var changeSecurityQuestionButton: UIButton = {
        let newValue = UIButton(type: .custom)
        set(title: TextConstants.userProfileEditSecretQuestion, for: newValue)
        newValue.addTarget(self, action: #selector(onChangeSecurityQuestion), for: .touchUpInside)
        newValue.contentHorizontalAlignment = .left
        return newValue
    }()
    
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
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var name: String?
    private var surname: String?
    private var email: String?
    private var phoneCode: String?
    private var recoveryEmail: String?
    private var phoneNumber: String?
    private var birthday: String?
    private var address: String?
    private var isTurkcellUser = false
    private var isShortPhoneNumber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.myProfile)
        addTapGestureToHideKeyboard()
        setupEditState(false)
        
        nameView.textField.delegate = self
        surnameView.textField.delegate = self
        emailView.textField.delegate = self
        phoneView.responderOnNext = birthdayDetailView
        recoveryEmailView.textField.delegate = self
        addressView.textField.delegate = self

        emailView.delegate = self
        recoveryEmailView.delegate = self
        
        // TODO: responderOnNext for birthdayDetailView
        //birthdayDetailView.textField.delegate = self
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBarWithGradientStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .myProfile, eventLabel: .back)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }
    
    func setupEditState(_ isEdit: Bool) {
        setRightBarButton(isEdit: isEdit)

        nameView.isEditState = isEdit
        surnameView.isEditState = isEdit
        emailView.isEditState = isEdit
        recoveryEmailView.isEditState = isEdit
        birthdayDetailView.isEditState = isEdit
        addressView.isEditState = isEdit
        
        /// phoneView disabled for Turkcell user
        if isTurkcellUser {
            isEdit ? phoneView.showTextAnimated(text: TextConstants.profileDetailErrorContactCallCenter) : phoneView.hideSubtitleAnimated()
        } else {
            phoneView.isEditState = isEdit
        }
        
        isEdit ? addressView.showSubtitleAnimated() : addressView.hideSubtitleAnimated()
        isEdit ? recoveryEmailView.showSubtitleAnimated() : recoveryEmailView.hideSubtitleAnimated()
    }

    private func setRightBarButton(isEdit: Bool) {
        let button = isEdit ? readyButton : editButton
        button.fixEnabledState()
        navigationItem.setRightBarButton(button, animated: true)
    }

    private func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.color = ColorConstants.whiteColor
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            setRightBarButton(isEdit: nameView.isEditState)
        }
    }

    @objc private func onChangePassword() {
        output.tapChangePasswordButton()
    }
    
    @objc private func onChangeSecurityQuestion() {
        output.tapChangeSecretQuestionButton()
    }
    
    @objc private func onEditButtonAction() {
        setupEditState(true)
        output.tapEditButton()
        saveFields()
    }
    
    @objc private func onReadyButtonAction() {
        updateProfile()
    }
    
    private func saveFields() {
        name = nameView.textField.text
        surname = surnameView.textField.text
        email = emailView.textField.text
        phoneCode = phoneView.codeTextField.text
        recoveryEmail = recoveryEmailView.textField.text
        phoneNumber = phoneView.numberTextField.text
        birthday = birthdayDetailView.editableText
        address = addressView.textField.text
    }
    
    private func updateProfile() {
        guard
            let name = nameView.textField.text,
            let surname = surnameView.textField.text,
            let email = emailView.textField.text,
            let phoneCode = phoneView.codeTextField.text,
            let recoveryEmail = recoveryEmailView.textField.text,
            let phoneNumber = phoneView.numberTextField.text,
            let birthday = birthdayDetailView.editableText,
            let address = addressView.textField.text,
            
            /// check for changes
            (self.name != name ||
            self.surname != surname ||
            self.email != email ||
            self.phoneCode != phoneCode ||
            self.recoveryEmail != recoveryEmail ||
            self.phoneNumber != phoneNumber ||
            self.birthday != birthday ||
            self.address != address)
        else {
            setupEditState(false)
            return
        }
        
        let sendingPhoneNumber = isShortPhoneNumber ? phoneNumber : "\(phoneCode)\(phoneNumber)"

        setIsLoading(true)

        if self.email != email {
            guard !email.isEmpty else {
                output.showError(error: TextConstants.emptyEmail)
                return
            }
            
            guard Validator.isValid(email: email) else {
                output.showError(error: TextConstants.notValidEmail)
                return
            }
            
            let message = String(format: TextConstants.registrationEmailPopupMessage, email)
            
            let controller = PopUpController.with(
                title: TextConstants.registrationEmailPopupTitle,
                message: message,
                image: .error,
                buttonTitle: TextConstants.ok,
                action: { [weak self] vc in
                    vc.close { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.output.tapReadyButton(name: name,
                                                    surname: surname,
                                                    email: email,
                                                    recoveryEmail: recoveryEmail,
                                                    number: sendingPhoneNumber,
                                                    birthday: birthday,
                                                    address: address,
                                                    changes: self.getChanges())
                    }
                })
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            output.tapReadyButton(name: name,
                                  surname: surname,
                                  email: email,
                                  recoveryEmail: recoveryEmail,
                                  number: sendingPhoneNumber,
                                  birthday: birthday,
                                  address: address,
                                  changes: getChanges())
        }
    }
    
    private func set(title: String, for button: UIButton) {
        let attributedString = NSAttributedString(string: title,
                                                  attributes: [
                                                    .font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                    .foregroundColor: UIColor.lrTealish,
                                                    .underlineStyle: NSUnderlineStyle.single.rawValue])
        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func getChanges() -> String {
        var changes: [String] = []
        let type = GAEventLabel.ProfileChangeType.self
        name != nameView.textField.text ? changes.append(type.name.text) : ()
        surname != surnameView.textField.text ? changes.append(type.surname.text) : ()
        email != emailView.textField.text ? changes.append(type.email.text) : ()
        phoneNumber != phoneView.numberTextField.text ? changes.append(type.phone.text) : ()
        birthday != birthdayDetailView.editableText ? changes.append(type.birthday.text) : ()
        address != addressView.textField.text ? changes.append(type.address.text) : ()
        return changes.joined(separator: "|")
    }
    
}

extension UserProfileViewController: ProfileEmailFieldViewDelegate {
    func profileEmailFieldViewVerifyTapped(_ fieldView: ProfileEmailFieldView) {
        switch fieldView {
        case emailView:
            presentEmailVerificationPopUp()

        case recoveryEmailView:
            presentRecoveryEmailVerificationPopUp()

        default:
            break
        }
    }
}

extension UserProfileViewController: BaseEmailVerificationPopUpDelegate {
    func emailVerificationPopUpCompleted(_ popup: BaseEmailVerificationPopUp) {
        // applies to both email & recovery email
        output.emailVerificationCompleted()
    }
}

extension UserProfileViewController: UITextFieldDelegate  {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        /// this logic maybe will be need
        //switch textField {
        //case nameView.textField:
        //    nameView.hideSubtitleAnimated()
        //
        //case surnameView.textField:
        //    surnameView.hideSubtitleAnimated()
        //
        //case emailView.textField:
        //    emailView.hideSubtitleAnimated()
        //
        //case birthdayDetailView.textField:
        //    break
        //
        //case phoneView.numberTextField, phoneView.codeTextField:
        //    phoneView.hideSubtitleAnimated()
        //
        //case addressView.textField:
        //    addressView.hideSubtitleAnimated()
        //
        //default:
        //    assertionFailure()
        //}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameView.textField:
            surnameView.textField.becomeFirstResponder()

        case surnameView.textField:
            emailView.textField.becomeFirstResponder()

        case emailView.textField:
            /// phoneView disabled for Turkcell user
            if isTurkcellUser {
                birthdayDetailView.textField.becomeFirstResponder()
            } else {
                phoneView.codeTextField.becomeFirstResponder()
            }

        /// setup in view.
        /// only for simulator.
        case phoneView.codeTextField:
            phoneView.numberTextField.becomeFirstResponder()

        /// only for simulator.
        /// setup by responderOnNext:
        case phoneView.numberTextField:
            recoveryEmailView.textField.becomeFirstResponder()

        case recoveryEmailView.textField:
            addressView.textField.becomeFirstResponder()

        /// only for simulator.
        /// setup by responderOnNext:
        case birthdayDetailView.textField:
            addressView.textField.becomeFirstResponder()
            
        case addressView.textField:
            updateProfile()

        default:
            assertionFailure()
        }
        
        return true
    }
    
}

extension UserProfileViewController: UserProfileViewInput {
    
    func configurateUserInfo(userInfo: AccountInfoResponse) {
        nameView.textField.text = userInfo.name
        surnameView.textField.text = userInfo.surname
        emailView.textField.text = userInfo.email
        emailView.showsVerificationStatus = userInfo.emailVerified != nil
        emailView.isVerified = userInfo.emailVerified ?? false
        recoveryEmailView.textField.text = userInfo.recoveryEmail
        recoveryEmailView.showsVerificationStatus = userInfo.recoveryEmailVerified != nil
        recoveryEmailView.isVerified = userInfo.recoveryEmailVerified ?? false
        addressView.textField.text = userInfo.address
        isTurkcellUser = userInfo.isTurkcellUser
        
        let securityQuestionButtonTitle = (userInfo.hasSecurityQuestionInfo == true) ? TextConstants.userProfileEditSecretQuestion : TextConstants.userProfileSetSecretQuestionButton
        set(title: securityQuestionButtonTitle, for: changeSecurityQuestionButton)
        
        if let countryCode = userInfo.countryCode, let phoneNumber = userInfo.phoneNumber {
            phoneView.codeTextField.text = "+\(countryCode)"
            
            /// there is no countryCode in phoneNumber for turkcell accounts
            if phoneNumber.contains(countryCode) {
                let plusLength = 1 /// "+".count
                let start = countryCode.count + plusLength
                let end = phoneNumber.count
                phoneView.numberTextField.text = phoneNumber[start..<end]
                isShortPhoneNumber = false
            } else {
                phoneView.numberTextField.text = phoneNumber
                isShortPhoneNumber = true
            }
        } else {
            assertionFailure("probles with userInfo: \(userInfo)")
        }
        
        let birthday = (userInfo.dob ?? "").replacingOccurrences(of: "-", with: " ")
        birthdayDetailView.configure(with: birthday, delegate: self)
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getPhoneNumber() -> String {
        return (phoneView.codeTextField.text ?? "") + (phoneView.numberTextField.text ?? "")
    }

    func endSaving() {
        setIsLoading(false)
    }
    
    func securityQuestionWasSet() {
        /// we need to update title if it was TextConstants.userProfileSetSecretQuestionButton
        /// can be added any check for title or userInfo.
        set(title: TextConstants.userProfileEditSecretQuestion, for: changeSecurityQuestionButton)
    }

    func presentEmailVerificationPopUp() {
        let popup = RouterVC().verifyEmailPopUp
        popup.alwaysShowsLaterButton = true
        popup.delegate = self
        present(popup, animated: true)
    }

    func presentRecoveryEmailVerificationPopUp() {
        let popup = RouterVC().verifyRecoveryEmailPopUp
        popup.delegate = self
        present(popup, animated: true)
    }
}
