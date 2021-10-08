//
//  VerifyEmailPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 7/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Typist

final class VerifyEmailPopUp: BasePopUpController {

    //MARK: IBOutlet

    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet private weak var topLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textColor = ColorConstants.textOrange
            newValue.isHidden = true
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var changeEmailButton: UIButton! {
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
    
    @IBOutlet private weak var resendCodeButton: UIButton! {
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

    @IBOutlet private weak var laterButton: RoundedInsetsButton! {
        willSet {
            newValue.layer.borderColor = UIColor.lrTealishTwo.cgColor
            newValue.layer.borderWidth = 1
            
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
            newValue.setTitle(TextConstants.later, for: .normal)
        }
    }
    
    @IBOutlet private weak var confirmButton: RoundedInsetsButton! {
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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var firstTextField: SecurityCodeTextField!
    
    @IBOutlet private var codeTextFields: [SecurityCodeTextField]!
    
    //MARK: Properties
    private let keyboard = Typist()
    private let activityManager = ActivityIndicatorManager()

    private lazy var accountService = AccountService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private var isRemoveLetter: Bool = false
    private var currentSecurityCode = ""
    private var inputTextLimit = 6
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        analyticsService.logScreen(screen: .verifyEmailPopUp)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.VerifyEmailPopUp())
    }
    
    //MARK: Utility methods
    private func setup() {
        setupKeyboard()
        
        activityManager.delegate = self
        
        updateEmail()
        
        contentView = popUpView

        #if DEBUG
        laterButton.isHidden = false
        #else
        let allowSkip = (SingletonStorage.shared.accountInfo?.emailVerificationRemainingDays ?? 0) > 0
        laterButton.isHidden = !allowSkip
        #endif
        
        codeTextFields.forEach({
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        })
        
        ///don't send code if just registered(code already sent)
        if SingletonStorage.shared.isNeedToSentEmailVerificationCode {
            resendCode(isAutomaticaly: true)
        }
    }
    
    private func updateEmail() {
        guard let email = SingletonStorage.shared.accountInfo?.email else {
            assertionFailure()
            return
        }
        
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
    
    private func enableConfirmButtonIfNeeded() {
        let isEnabled = currentSecurityCode.count == inputTextLimit
        
        if confirmButton.isEnabled != isEnabled {
            confirmButton.isEnabled = isEnabled
            
            let alphaComponent: CGFloat = isEnabled ? 1 : 0.5
            confirmButton.layer.borderColor = UIColor.lrTealishTwo.withAlphaComponent(alphaComponent).cgColor
        }
    }
    
    private func hidePopUp(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.clearCode()
            self.errorLabel.isHidden = true
            
            completion?()
        })
        
    }
    
    private func showPopUp() {
        updateEmail()
        
        analyticsService.logScreen(screen: .verifyEmailPopUp)

        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
        }
    }
    
    private func dismissPopUp(animated: Bool = true) {
        close()
    }
    
    private func showError(text: String) {
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
    
    private func clearCode() {
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
        analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                            eventActions: .otp,
                                            eventLabel: .changeEmail)
        
        hidePopUp { [weak self] in
            let router = RouterVC()
            let controller = router.changeEmailPopUp
            controller.completion = { [weak self] in
                self?.showPopUp()
            }
            
            UIApplication.topController()?.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func onLaterTap(_ sender: Any) {
        analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                            eventActions: .otp,
                                            eventLabel: .later)
        
        dismissPopUp()
    }
    
    @IBAction func onConfirmTap(_ sender: Any) {
        hideKeyboard()
        verificationCodeEntered()
    }
}

//MARK: - Interactor
extension VerifyEmailPopUp {
    private func verificationCodeEntered() {
        startActivityIndicator()
        
        accountService.verifyEmail(otpCode: currentSecurityCode) { [weak self] response in
            self?.stopActivityIndicator()
            
            switch response {
            case .success(_):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .confirmStatus(isSuccess: true))
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EmailVerification(action: .success))
                DispatchQueue.main.async { [weak self] in
                    self?.hidePopUp {
                        let popUp = EmailVerifiedPopUp.with(image: .custom(UIImage(named: "Path")),
                                                            message: TextConstants.accountVerified,
                                                            buttonTitle: TextConstants.createStoryPhotosContinue) { [weak self] in
                                                                self?.dismissPopUp(animated: false)
                                                                
                        }
                        
                        popUp.modalPresentationStyle = .overFullScreen
                        popUp.modalTransitionStyle = .crossDissolve
                        
                        UIApplication.topController()?.present(popUp, animated: true, completion: nil)
                    }

                }
                
            case .failed(let error):
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EmailVerification(action: .failure))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .confirmStatus(isSuccess: false),
                                                          errorType: GADementionValues.errorType(with: error.localizedDescription))
                
                DispatchQueue.main.async { [weak self] in
                    self?.showError(text: error.localizedDescription)
                    self?.clearCode()
                    self?.enableConfirmButtonIfNeeded()
                }
            }
        }
    }
    
    private func resendCode(isAutomaticaly: Bool = false) {
        startActivityIndicator()
        
        accountService.sendEmailVerificationCode { [weak self] response in
            self?.stopActivityIndicator()
            
            switch response {
            case .success(_):
                if isAutomaticaly {
                    SingletonStorage.shared.isEmailVerificationCodeSent = true
                } else {
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                              eventActions: .otp,
                                                              eventLabel: .codeResent(isSuccessed: true))
                }
                
                break
            case .failed(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .emailVerification,
                                                          eventActions: .otp,
                                                          eventLabel: .codeResent(isSuccessed: false),
                                                          errorType: GADementionValues.errorType(with: error.localizedDescription))

                DispatchQueue.main.async { [weak self] in
                    self?.clearCode()
                    self?.enableConfirmButtonIfNeeded()
                    self?.showError(text: error.localizedDescription)
                }
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension VerifyEmailPopUp: UITextFieldDelegate {
    
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
extension VerifyEmailPopUp: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}
