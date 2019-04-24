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
    
    var quotaInfo: QuotaInfoResponse?
    
    var isPremiumUser: Bool {
        return AuthoritySingleton.shared.accountType.isPremium
    }
    
    var isMiddleUser: Bool {
        return AuthoritySingleton.shared.accountType.isMiddle
    }
    
    func requestsFinished() {
        asyncOperationSuccess()
    }
    
    func setUserInfo(userInfo: AccountInfoResponse) {
        view.setUserInfo(userInfo: userInfo)
    }
    
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        self.quotaInfo = quotoInfo
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
        asyncOperationSuccess()
        startAsyncOperation()
    }
    
    func loadingIndicatorDismissalRequired() {
        asyncOperationSuccess()
    }
    
    func failedWith(error: Error) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }

}
