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
    
    func requestsFinished() {
        asyncOperationSucces()
    }
    
    func setUserInfo(userInfo: AccountInfoResponse) {
        view.setUserInfo(userInfo: userInfo)
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        view.setQuotaInfo(quotoInfo: quotoInfo)
    }

    func reloadUserInfoRequired() {
        showSpinner()
        interactor.onStartRequests()
    }
    
    func loadingIndicatorRequired() {
        showSpinner()
    }

    private func showSpinner() {
        asyncOperationSucces()
        startAsyncOperation()
    }
    
    func loadingIndicatorDismissalRequired() {
        asyncOperationSucces()
    }
    
    func failedWith(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }

}
