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
    
    func tapEditButton() {
        view.setupEditState(true)
        interactor.trackState(.edit, errorType: nil)
    }
    
    func tapReadyButton(name: String, surname: String, email: String, number: String, birthday: String, address: String, changes: String) {
        interactor.changeTo(name: name, surname: surname, email: email, number: number, birthday: birthday, address: address, changes: changes)
    }
    
    func dataWasUpdated() {
        view.setupEditState(false)
    }
    
    func isTurkcellUser() -> Bool {
        return interactor.statusTurkcellUser
    }
    
    func tapChangePasswordButton() {
        router.goToChangePassword()
    }
    
    func tapChangeSecretQuestionButton() {
        interactor.trackSetSequrityQuestion()
        router.goToSetSecretQuestion(selectedQuestion: interactor.secretQuestionsResponse,
                                     delegate: self)
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
