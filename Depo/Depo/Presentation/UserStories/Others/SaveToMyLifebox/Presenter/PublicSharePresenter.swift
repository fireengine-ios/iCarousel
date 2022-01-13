//
//  PublicSharePresenter.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicSharePresenter: BasePresenter, PublicShareModuleInput {
    var view: PublicShareViewInput!
    var interactor: PublicShareInteractorInput!
    var router: PublicShareRouterInput!
    
    override func outputView() -> Waiting? {
        return view
    }
    
}

extension PublicSharePresenter: PublicShareViewOutput {
    func fetchMoreIfNeeded() {
        interactor.fetchMoreIfNeeded()
    }
    
    func onSelect(item: WrapData) {
        router.onSelect(item: item)
    }
    
    func viewIsReady() {
        interactor.fetchData()
    }
    
    func savePublicSharedItems() {
        interactor.savePublicSharedItems()
    }
}

extension PublicSharePresenter: PublicShareInteractorOutput {
    func saveOperationSuccess() {
        router.popToRoot()
        view.saveOperationSuccess()
        asyncOperationSuccess()
    }
    
    func operationSuccess(with items: [SharedFileInfo]) {
        view.didGetSharedItems(items: items)
        asyncOperationSuccess()
    }
    
    func operationFailedWithError(errorMessage: String, needReturn: Bool) {
        if needReturn {
            router.popToRoot()
        }
        asyncOperationFail(errorMessage: errorMessage)
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func startProgress() {
        startAsyncOperation()
    }
}
