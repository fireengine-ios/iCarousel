//
//  UsageInfoPresenter.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class UsageInfoPresenter: BasePresenter {
    weak var view: UsageInfoViewInput!
    var interactor: UsageInfoInteractorInput!
    var router: UsageInfoRouterInput!
    
    //MARK : BasePresenter
    override func outputView() -> Waiting? {
        return view
    }
}

// MARK: - UsageInfoViewOutput
extension UsageInfoPresenter: UsageInfoViewOutput {
    func viewIsReady() {
        interactor.trackScreen()
    }
    
    func viewWillAppear() {
        startAsyncOperation()
        interactor.getUsage()
    }
    
    func upgradeButtonPressed(with navVC: UINavigationController?) {
        router.showPackages(navVC: navVC)
    }
}

// MARK: - UsageInfoInteractorOutput
extension UsageInfoPresenter: UsageInfoInteractorOutput {
    func successed(usage: UsageResponse) {
        view.display(usage: usage)
        asyncOperationSuccess()
    }
    
    func failedUsage(with error: ErrorResponse) {
        asyncOperationSuccess()
        view.display(error: error)
    }
}
