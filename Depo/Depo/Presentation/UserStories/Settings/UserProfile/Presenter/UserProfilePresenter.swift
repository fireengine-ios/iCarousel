//
//  UserProfileUserProfilePresenter.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfilePresenter: BasePresenter, UserProfileModuleInput, UserProfileViewOutput, UserProfileInteractorOutput {

    weak var view: UserProfileViewInput!
    var interactor: UserProfileInteractorInput!
    var router: UserProfileRouterInput!
    var appearAction: UserProfileAppearAction?

    private var viewAppearedBefore = false
    
    // MARK: Utility methods
    private func getPhoneWithAddedCodeIfNeeded() -> String {
        var phoneNumber = view.getPhoneNumber()
        
        if !phoneNumber.contains("+") {
            phoneNumber = CoreTelephonyService().callingCountryCode() + phoneNumber
        } 
        
        return phoneNumber
    }

    // interactor out
    
    func configurateUserInfo(userInfo: AccountInfoResponse) {
        view.configurateUserInfo(userInfo: userInfo)
    }
    
    func startNetworkOperation() {
        startAsyncOperation()
    }
    
    func stopNetworkOperation() {
        asyncOperationSuccess()
    }
    
    func needSendOTP(response: SignUpSuccessResponse, userInfo: AccountInfoResponse) {
        view.endSaving()
        view.setupEditState(false)
        if let navigationController = view.getNavigationController() {
            router.needSendOTP(response: response, userInfo: userInfo, navigationController: navigationController, phoneNumber: getPhoneWithAddedCodeIfNeeded())
        }
    }
    
    func showError(error: String) {
        view.endSaving()
                
        interactor.trackState(.save(isSuccess: false), errorType: GADementionValues.errorType(with: error))
        
        UIApplication.showErrorAlert(message: error)
    }
    
    //view out
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.setupEditState(false)
    }

    func viewDidAppear() {
        guard viewAppearedBefore == false else { return }
        viewAppearedBefore = true

        switch appearAction {
        case .none:
            break

        case .presentVerifyEmail:
            if interactor.userInfo?.emailVerified == false {
                view?.presentEmailVerificationPopUp()
            }

        case .presentVerifyRecoveryEmail:
            if interactor.userInfo?.recoveryEmailVerified == false {
                view?.presentRecoveryEmailVerificationPopUp()
            }
        }
    }
    
    func tapEditButton() {
        view.setupEditState(true)
        interactor.trackState(.edit, errorType: nil)
    }
    
    func tapReadyButton(name: String, surname: String, email: String, recoveryEmail: String,
                        number: String, birthday: String, address: String, changes: String) {
        interactor.changeTo(name: name, surname: surname, email: email, recoveryEmail: recoveryEmail,
                            number: number, birthday: birthday, address: address, changes: changes)
    }
    
    func dataWasUpdated() {
        view.setupEditState(false)
    }
    
    func isTurkcellUser() -> Bool {
        return interactor.statusTurkcellUser
    }
    
    func tapChangePasswordButton() {
        interactor.getUpdatePasswordMethods()
    }
    
    func gotUpdatePasswordMethod(method: UpdatePasswordMethods) {
        stopNetworkOperation()
        if method == .password {
            router.goToChangePassword()
        } else {
            if #available(iOS 13, *) {
                view.setNewPassword(with: method)
            } else {
                view.presentForgetPasswordPopup()
            }
        }
    }
    
    func tapChangeSecretQuestionButton() {
        interactor.trackSetSequrityQuestion()
        router.goToSetSecretQuestion(selectedQuestion: interactor.secretQuestionsResponse,
                                     delegate: self)
    }

    func tapDeleteMyAccount() {
        interactor.trackDeleteMyAccount()
        router.presentDeleteAccountFirstPopUp { [weak self] popup in
            popup.dismiss(animated: true) {
                self?.router.presentDeleteAccountValidationPopUp(delegate: self!)
            }
        }
    }

    func emailVerificationCompleted() {
        interactor.forceRefreshUserInfo()
    }

    func deleteMyAccountValidatedAndConfirmed() {
        interactor.deleteMyAccount()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}

extension UserProfilePresenter: SetSecurityQuestionViewControllerDelegate {
    func didCloseSetSecurityQuestionViewController(with selectedQuestion: SecretQuestionWithAnswer) {
        interactor.updateUserInfo()
        interactor.updateSecretQuestionsResponse(with: selectedQuestion)
        view.securityQuestionWasSet()
    }
}

extension UserProfilePresenter: DeleteAccountValidationPopUpDelegate {
    func deleteAccountValidationPopUpSucceeded(_ popup: DeleteAccountValidationPopUp) {
        popup.dismiss(animated: true) {
            self.router.presentDeleteAccountFinalPopUp { [weak self] popup in
                popup.dismiss(animated: true)
                self?.interactor.deleteMyAccount()
            }
        }
    }
}

