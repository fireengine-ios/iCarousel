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
    func popViewController() {
        router.popToRoot()
    }
    
    func fetchMoreIfNeeded() {
        interactor.fetchMoreIfNeeded()
    }
    
    func onSelect(item: WrapData) {
        router.onSelect(item: item)
    }
    
    func viewIsReady() {
        interactor.fetchData()
    }
    
    func onSaveButton(isLoggedIn: Bool) {
        if isLoggedIn {
            interactor.savePublicSharedItems()
        } else {
            router.navigateToOnboarding()
        }
    }
}

extension PublicSharePresenter: PublicShareInteractorOutput {
    func saveOperationFail(errorMessage: String) {
        router.popToRoot()
        view.saveOpertionFail(errorMessage: errorMessage)
        router.navigateToAllFiles()
    }
    
    func saveOperationSuccess() {
        router.popToRoot()
        view.saveOperationSuccess()
        router.navigateToAllFiles()
        asyncOperationSuccess()
    }
    
    func operationSuccess(with items: [SharedFileInfo]) {
        view.didGetSharedItems(items: items)
        asyncOperationSuccess()
    }
    
    func operationFailedWithError(errorMessage: String) {
        router.popToRoot()
        asyncOperationFail(errorMessage: errorMessage)
    }
    
    func startProgress() {
        startAsyncOperation()
    }
}
