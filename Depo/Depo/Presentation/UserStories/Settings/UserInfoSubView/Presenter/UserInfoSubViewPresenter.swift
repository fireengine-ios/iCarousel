//
//  UserInfoSubViewUserInfoSubViewPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserInfoSubViewPresenter: BasePresenter, UserInfoSubViewModuleInput, UserInfoSubViewViewOutput, UserInfoSubViewInteractorOutput {

    weak var view: UserInfoSubViewViewInput!
    var interactor: UserInfoSubViewInteractorInput!
    var router: UserInfoSubViewRouterInput!

    func viewIsReady() {
        startAsyncOperation()
        interactor.onStartRecuests()
    }
    
    func requestsFinished(){
        asyncOperationSucces()
    }
    
    func setUserInfo(userInfo: AccountInfoResponse){
        view.setUserInfo(userInfo: userInfo)
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse){
        view.setQuotaInfo(quotoInfo: quotoInfo)
    }

    func reloadUserInfoRequered() {
        showSpinner()
        interactor.onStartRecuests()
    }
    
    func loadingIndicatorRequered() {
        showSpinner()
    }

    private func showSpinner() {
        asyncOperationSucces()
        startAsyncOperation()
    }
    
    func loadingIndicatorDismissalRequered() {
        asyncOperationSucces()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }

}
