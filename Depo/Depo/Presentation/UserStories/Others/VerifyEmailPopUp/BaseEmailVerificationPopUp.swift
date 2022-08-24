//
//  BaseEmailVerificationPopUp.swift
//  Depo
//
//  Created by Hady on 9/7/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import Typist

protocol BaseEmailVerificationPopUpDelegate: AnyObject {
    func emailVerificationPopUpCompleted(_ popup: BaseEmailVerificationPopUp)
}

class BaseEmailVerificationPopUp: BasePopUpController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: String(describing: BaseEmailVerificationPopUp.self), bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: IBOutlet

    @IBOutlet weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4

            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }

    @IBOutlet weak var topLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
        }
    }

    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textColor = ColorConstants.textOrange
            newValue.isHidden = true
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet weak var changeEmailButton: UIButton! {
        willSet {
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.lrTealishTwo,
                .underlineStyle : NSUnderlineStyle.single.rawValue,
                .font : UIFont.TurkcellSaturaMedFont(size: 15),
            ]

            let attirbutedString = NSAttributedString(string: TextConstants.changeEmail, attributes: attributes)
            newValue.setAttributedTitle(attirbutedString, for: .normal)

            newValue.titleLabel?.numberOfLines = 0
        }
    }

    @IBOutlet weak var resendCodeButton: UIButton! {
        willSet {
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.lrTealishTwo,
                .underlineStyle : NSUnderlineStyle.single.rawValue,
                .font : UIFont.TurkcellSaturaMedFont(size: 15),
            ]

            let attirbutedString = NSAttributedString(string: TextConstants.resendCode, attributes: attributes)
            newValue.setAttributedTitle(attirbutedString, for: .normal)

            newValue.titleLabel?.numberOfLines = 0
        }
    }

    @IBOutlet weak var laterButton: RoundedInsetsButton! {
        willSet {
            newValue.layer.borderColor = UIColor.lrTealishTwo.cgColor
            newValue.layer.borderWidth = 1

            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
            newValue.setTitle(TextConstants.later, for: .normal)
        }
    }

    @IBOutlet weak var confirmButton: RoundedInsetsButton! {
        willSet {
            newValue.layer.borderColor = UIColor.lrTealishTwo.withAlphaComponent(0.5).cgColor
            newValue.layer.borderWidth = 1

            newValue.setTitle(TextConstants.confirm, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)

            newValue.setBackgroundColor(UIColor.lrTealishTwo, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealishTwo.withAlphaComponent(0.5), for: .disabled)

            newValue.isEnabled = false
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var firstTextField: SecurityCodeTextField!

    @IBOutlet var codeTextFields: [SecurityCodeTextField]!

    //MARK: Properties
    let keyboard = Typist()
    let activityManager = ActivityIndicatorManager()

    lazy var accountService = AccountService()
    lazy var analyticsService: AnalyticsService = factory.resolve()

    var isRemoveLetter: Bool = false
    var currentSecurityCode = ""
    var inputTextLimit = 6
    var alwaysShowsLaterButton = false

    weak var delegate: BaseEmailVerificationPopUpDelegate?

    // MARK: Abstract

    var email: String {
        assertionFailure("Implement in concrete class")
        return ""
    }

    var verificationRemainingDays: Int {
        assertionFailure("Implement in concrete class")
        return 0
    }

    func createChangeEmailPopUp() -> BaseChangeEmailPopUp {
        assertionFailure("Implement in concrete class")
        return BaseChangeEmailPopUp()
    }

    func verificationCodeEntered() {
        assertionFailure("Implement in concrete class")
    }

    func resendCode(isAutomaticaly: Bool = false) {
        assertionFailure("Implement in concrete class")
    }

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    //MARK: Utility methods
    func setup() {
        setupKeyboard()

        activityManager.delegate = self

        contentView = popUpView

        codeTextFields.forEach({
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })

        updateEmail()

        #if DEBUG
        laterButton.isHidden = false
        #else
        let allowSkip = verificationRemainingDays > 0
        laterButton.isHidden = !allowSkip && !alwaysShowsLaterButton
        #endif
    }

    private func updateEmail() {
        let topText = String(format: TextConstants.verifyEmailTopTitle, TextConstants.enterTheSecurityCode, email)

        let attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.TurkcellSaturaMedFont(size: 15),
            .foregroundColor : ColorConstants.blueGrey,
            .kern : 0.0
        ]

        let attributedText = NSMutableAttributedString(string: topText, attributes: attributes)

        if let range = topText.range(of: TextConstants.enterTheSecurityCode) {
            let rangeAttributes: [NSAttributedString.Key : Any] = [
                .foregroundColor : AppColor.blackColor.color
            ]
            let nsRange = NSRange(location: range.lowerBound.encodedOffset,
                                  length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
            attributedText.addAttributes(rangeAttributes, range: nsRange)
        }

        topLabel.attributedText = attributedText
    }

    func enableConfirmButtonIfNeeded() {
        let isEnabled = currentSecurityCode.count == inputTextLimit

        if confirmButton.isEnabled != isEnabled {
            confirmButton.isEnabled = isEnabled

            let alphaComponent: CGFloat = isEnabled ? 1 : 0.5
            confirmButton.layer.borderColor = UIColor.lrTealishTwo.withAlphaComponent(alphaComponent).cgColor
        }
    }

    func hidePopUp(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.clearCode()
            self.errorLabel.isHidden = true

            completion?()
        })
    }

    func showCompletedAndClose() {
        delegate?.emailVerificationPopUpCompleted(self)

        let popUp = EmailVerifiedPopUp.with(image: .custom(UIImage(named: "Path")),
                                            message: TextConstants.accountVerified,
                                            buttonTitle: TextConstants.createStoryPhotosContinue) { [weak self] in
            self?.dismissPopUp(animated: false)
        }

        popUp.modalPresentationStyle = .overFullScreen
        popUp.modalTransitionStyle = .crossDissolve

        UIApplication.topController()?.present(popUp, animated: true, completion: nil)
    }

    func showPopUp() {
        updateEmail()


        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
        }
    }

    func dismissPopUp(animated: Bool = true) {
        close()
    }

    func showError(text: String) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.text = text
            self.errorLabel.isHidden = false
        }
    }

    //MARK: keyboard processing
    private func setupKeyboard() {
        keyboard
            .on(event: .willShow) { [weak self] options in
                guard let `self` = self else {
                    return
                }

                let bottomInset = options.endFrame.height - self.scrollView.safeAreaInsets.bottom

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
            }
            .on(event: .didShow, do: { [weak self] options in
                guard let `self` = self else {
                    return
                }

                let rectToScroll = self.view.convert(self.popUpView.frame, to: self.view)
                let rectToScrollWithOffset = rectToScroll.offsetBy(dx: 0, dy: 16)

                self.scrollView.scrollRectToVisible(rectToScrollWithOffset, animated: true)
            })
            .on(event: .willHide) { [weak self] options in
                guard let `self` = self else {
                    return
                }

                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            .start()
    }

    private func hideKeyboard() {
        view.endEditing(true)
    }

    //MARK: text feild processing
    @objc private func textFieldDidChange(_ sender: UITextField) {
        errorLabel.isHidden = true

        if isRemoveLetter {
            let previosTag = sender.tag - 1
            if let nextResponder = codeTextFields[safe: previosTag] {
                nextResponder.becomeFirstResponder()
            }
        } else {
            let nextTag = sender.tag + 1
            if let nextResponder = codeTextFields[safe: nextTag] {
                nextResponder.becomeFirstResponder()
            } else {
                hideKeyboard()
            }
        }
    }

    func clearCode() {
        currentSecurityCode.removeAll()
        codeTextFields.forEach { $0.text = "" }
    }

    //MARK: Actions
    @IBAction func startEnteringCode(_ sender: Any) {
        errorLabel.isHidden = true

        var isTextFieldChosen = false

        for textField in codeTextFields {
            if let text = textField.text, text.removingWhiteSpaces().isEmpty {
                isTextFieldChosen = true
                textField.becomeFirstResponder()
                break
            }
        }

        if !isTextFieldChosen {
            codeTextFields.last?.becomeFirstResponder()
        }
    }

    @IBAction func onResendCodeTap(_ sender: Any) {
        hideKeyboard()
        clearCode()
        resendCode()
    }

    @IBAction func onChangeEmailTap(_ sender: Any) {
        hidePopUp {
            let controller = self.createChangeEmailPopUp()
            controller.completion = { [weak self] in
                self?.showPopUp()
            }

            UIApplication.topController()?.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func onLaterTap(_ sender: Any) {
        dismissPopUp()
    }

    @IBAction func onConfirmTap(_ sender: Any) {
        hideKeyboard()
        verificationCodeEntered()
    }
}

//MARK: - UITextFieldDelegate
extension BaseEmailVerificationPopUp: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// if the string is empty, then when deleting, the delegate method does not work
        textField.text = " "

        ///if reenter the code we need to remove last letter
        if currentSecurityCode.count == inputTextLimit {
            currentSecurityCode.removeLast()
            enableConfirmButtonIfNeeded()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isRemoveLetter = string.isEmpty

        if isRemoveLetter, currentSecurityCode.hasCharacters {
            currentSecurityCode.removeLast()

            return true
        }

        /// clear the space that we added to work delegate methods with an empty string
        textField.text = ""

        let notAvailableCharacterSet = CharacterSet.decimalDigits.inverted

        let result = string.rangeOfCharacter(from: notAvailableCharacterSet)
        if result != nil {
            return false
        }

        let currentStr = currentSecurityCode + string

        if currentStr.count == inputTextLimit {
            currentSecurityCode.append(contentsOf: string)
            enableConfirmButtonIfNeeded()
            return true

        } else if currentStr.count > NumericConstants.verificationCharacterLimit {
            return false

        }

        currentSecurityCode.append(contentsOf: string)

        return true
    }

}

//MARK: - ActivityIndicator
extension BaseEmailVerificationPopUp: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }

    func stopActivityIndicator() {
        activityManager.stop()
    }
}
