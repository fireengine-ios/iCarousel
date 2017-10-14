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
    
    func configurateUserInfo(userInfo: AccountInfoResponse){
        view.configurateUserInfo(userInfo: userInfo)
    }
    
    func setEditButtonEnable(enable: Bool){
        view.setEditButtonEnable(enable: enable)
    }
    
    func startNetworkOperation(){
        startAsyncOperation()
    }
    
    func stopNetworkOperation(){
        asyncOperationSucces()
    }
    
    //view out
    
    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func fieldsValueChanged(name: String, email: String, number: String){
        interactor.fieldsValueChanged(name: name, email: email, number: number)
    }
    
    func onEditButton(name: String, email: String, number: String){
        interactor.onEditButton(name: name, email: email, number: number)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
