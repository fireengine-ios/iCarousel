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
    
    func needSendOTP(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse) {
        view.endSaving()
        view.setupEditState(false)
        if let navigationController = view.getNavigationController() {
            router.needSendOTP(responce: responce, userInfo: userInfo, navigationController: navigationController, phoneNumber: view.getPhoneNumber())
        }
    }
    
    func showError(error: String) {
        view.endSaving()
        UIApplication.showErrorAlert(message: error)
    }
    
    //view out
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.setupEditState(false)
    }
    
    func tapEditButton() {
        view.setupEditState(true)
    }
    
    func tapReadyButton(name: String, email: String, number: String) {
        interactor.changeTo(name: name, email: email, number: number)
    }
    
    func dataWasUpdate() {
        view.setupEditState(false)
    }
    
    func isTurkcellUser() -> Bool {
        return interactor.statusTurkcellUser
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
