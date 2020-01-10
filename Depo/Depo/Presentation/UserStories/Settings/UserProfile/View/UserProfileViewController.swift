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
            
            newValue.addArrangedSubview(fullnameStackView)
            newValue.addArrangedSubview(emailView)
            newValue.addArrangedSubview(phoneView)
            newValue.addArrangedSubview(birthdayDetailView)
            newValue.addArrangedSubview(addressView)
            newValue.addArrangedSubview(changePasswordButton)
            newValue.addArrangedSubview(changeSecurityQuestionButton)
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
        newValue.textField.quickDismissPlaceholder = TextConstants.enterYourEmailAddress
        newValue.textField.keyboardType = .emailAddress
        newValue.textField.autocorrectionType = .no
        newValue.textField.autocapitalizationType = .none
        return newValue
    }()
    
    let phoneView = ProfilePhoneEnterView()
    
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
    
    private var name: String?
    private var surname: String?
    private var email: String?
    private var phoneCode: String?
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
        addressView.textField.delegate = self
        
        // TODO: responderOnNext for birthdayDetailView
        //birthdayDetailView.textField.delegate = self
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBarWithGradientStyle()
    }
    
    func setupEditState(_ isEdit: Bool) {
        let button = isEdit ? readyButton : editButton
        button.fixEnabledState()
        navigationItem.setRightBarButton(button, animated: true)
        
        nameView.isEditState = isEdit
        surnameView.isEditState = isEdit
        emailView.isEditState = isEdit
        birthdayDetailView.isEditState = isEdit
        addressView.isEditState = isEdit
        
        /// phoneView disabled for Turkcell user
        if isTurkcellUser {
            isEdit ? phoneView.showTextAnimated(text: TextConstants.profileDetailErrorContactCallCenter) : phoneView.hideSubtitleAnimated()
        } else {
            phoneView.isEditState = isEdit
        }
        
        isEdit ? addressView.showSubtitleAnimated() : addressView.hideSubtitleAnimated()
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
            let phoneNumber = phoneView.numberTextField.text,
            let birthday = birthdayDetailView.editableText,
            let address = addressView.textField.text,
            
            /// check for changes
            (self.name != name ||
            self.surname != surname ||
            self.email != email ||
            self.phoneCode != phoneCode ||
            self.phoneNumber != phoneNumber ||
            self.birthday != birthday ||
            self.address != address)
        else {
            setupEditState(false)
            return
        }
        
        let sendingPhoneNumber = isShortPhoneNumber ? phoneNumber : "\(phoneCode)\(phoneNumber)"
        
        readyButton.isEnabled = false
        
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
                        self?.output.tapReadyButton(name: name,
                                                    surname: surname,
                                                    email: email,
                                                    number: sendingPhoneNumber,
                                                    birthday: birthday,
                                                    address: address)
                        self?.readyButton.fixEnabledState()
                    }
                })
            
            self.present(controller, animated: true, completion: nil)
            
        } else {
            output.tapReadyButton(name: name,
                                  surname: surname,
                                  email: email,
                                  number: sendingPhoneNumber,
                                  birthday: birthday,
                                  address: address)
        }
    }
    
    private func set(title: String, for button: UIButton) {
        let attributedString = NSAttributedString(string: title,
                                                  attributes: [
                                                    .font: UIFont.TurkcellSaturaDemFont(size: 18),
                                                    .foregroundColor: UIColor.lrTealish,
                                                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        button.setAttributedTitle(attributedString, for: .normal)
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
            birthdayDetailView.textField.becomeFirstResponder()

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
        navigationItem.rightBarButtonItem?.fixEnabledState()
    }
    
    func securityQuestionWasSet() {
        /// we need to update title if it was TextConstants.userProfileSetSecretQuestionButton
        /// can be added any check for title or userInfo.
        set(title: TextConstants.userProfileEditSecretQuestion, for: changeSecurityQuestionButton)
    }
    
}
