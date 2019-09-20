//
//  PhoneVerificationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVerificationPresenter: BasePresenter, PhoneVerificationModuleInput, PhoneVerificationViewOutput, PhoneVerificationInteractorOutput {

    weak var view: PhoneVerificationViewInput!
    var interactor: PhoneVerificationInteractorInput!
    var router: PhoneVerificationRouterInput!
    
    var currentSecurityCode = ""

    private lazy var customProgressHUD = CustomProgressHUD()
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    func viewIsReady() {
        interactor.trackScreen()
        view.setupInitialState()
        configure()
        view.setupButtonsInitialState()
        interactor.resendCode()
    }
    
    func configure() {
        view.setupTextLengh(lenght: interactor.expectedInputLength ?? 6 )
        view.setupPhoneLable(with: interactor.textDescription, number: interactor.phoneNumber)
    }
    
    func timerFinishedRunning(with isShowMessageWithDropTimer: Bool) {
        if isShowMessageWithDropTimer {
            view.showError(TextConstants.timeIsUpForCode)
        }
        
        view.resendButtonShow(show: true)
        view.updateEditingState()
    }
    
    func resendButtonPressed() {
        view.resendButtonShow(show: false)
        view.updateEditingState()
        startAsyncOperationDisableScreen()
        interactor.resendCode()
        
    }
    
    func verificationCodeEntered() {
        startAsyncOperationDisableScreen()
        interactor.verifyCode(code: currentSecurityCode)
    }
    
    func verificationCodeNotReady() {
    }
    
    func verificationSucces() {
        interactor.authificate(atachedCaptcha: nil)
    }
    
    func verificationSilentSuccess() {
        /// empty bcz PhoneVerificationPresenter reused
    }
    
    func verificationFailed(with error: String) {
        completeAsyncOperationEnableScreen()
        view.updateEditingState()
        view.showError(error)
    }
    
    func resendCodeRequestFailed(with error: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        view.resendButtonShow(show: true)
        view.updateEditingState()
        
        if case ErrorResponse.error(let containedError) = error, let serverError = containedError as? ServerError, serverError.code == 401 {
            router.popToLoginWithPopUp(title: TextConstants.errorAlert, message: TextConstants.twoFAInvalidSessionErrorMessage, image: .error, onClose: nil)
        } else if error.description.contains(ErrorResponseText.resendCodeExceeded) {
            view.showError(TextConstants.TOO_MANY_REQUESTS)
        } else {
            view.showError(TextConstants.phoneVerificationResendRequestFailedErrorText)
        }
        
        view.dropTimer()
    }
    
    func resendCodeRequestSucceeded() {
        completeAsyncOperationEnableScreen()
        asyncOperationSuccess()
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInSeconds)
    }
    
    func succesLogin() {
        completeAsyncOperationEnableScreen()
        view.dropTimer()
        
        openAutoSyncIfNeeded()
    }
    
    func failLogin(message: String) {
        asyncOperationSuccess()
        completeAsyncOperationEnableScreen(errorMessage: message)
    }
    
    func didRedirectToSplash() {
        completeAsyncOperationEnableScreen()
        router.showRedirectToSplash()
    }
    
    func reachedMaxAttempts() {
        view.resendButtonShow(show: true)
        view.updateEditingState()
        view.dropTimer()
    }
    
    func currentSecurityCodeChanged(with newNumeric: String) {
        currentSecurityCode.append(contentsOf: newNumeric)
    }
    
    func currentSecurityCodeRemoveCharacter() {
        if !currentSecurityCode.isEmpty {
            currentSecurityCode.removeLast()
        }
    }
    
    func clearCurrentSecurityCode() {
        currentSecurityCode = ""
    }
    
    func loginDeletedAccount(deletedAccountHandler: @escaping VoidHandler) {
        completeAsyncOperationEnableScreen()

        let image = UIImage(named: "Path")
        let title = TextConstants.accountStatusTitle
        
        let titleFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaFont(size: 18),
            .foregroundColor : UIColor.black,
            .kern : 0
        ]
        
        let message = TextConstants.accountStatusMessage
        
        let messageParagraphStyle = NSMutableParagraphStyle()
        messageParagraphStyle.paragraphSpacing = 8
        messageParagraphStyle.alignment = .center
        
        let messageFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaMedFont(size: 16),
            .foregroundColor : ColorConstants.blueGrey,
            .paragraphStyle : messageParagraphStyle,
            .kern : 0
        ]
        
        router.showAccountStatePopUp(image: .custom(image),
                                     title: title,
                                     titleDesign: .partly(parts: [title : titleFullAttributes]),
                                     message: message,
                                     messageDesign: .partly(parts: [message : messageFullAttributes]),
                                     buttonTitle: TextConstants.ok,
                                     buttonAction: deletedAccountHandler)
    }

    
    // MARK: - Utility methods
    private func openAutoSyncIfNeeded() {
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpinner()
            
            /// from registration
            if needToOpenAutoSync {
                self?.router.goAutoSync()
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    // MARK: - Basic Presenter override
    override func outputView() -> Waiting? {
        return view
    }
    
}
