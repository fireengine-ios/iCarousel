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
    
    func onSelect(item: WrapData, items: [WrapData]) {
        router.onSelect(item: item, items: items)
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
    func saveOperationStorageFail() {
        router.navigateToHomeScreen()
        router.presentFullQuotaPopup()
    }
    
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
    
    func listOperationSuccess(with items: [SharedFileInfo]) {
        view.didGetSharedItems(items: items)
        asyncOperationSuccess()
    }
    
    func listOperationFail(errorMessage: String, isInnerFolder: Bool) {
        if isInnerFolder {
            router.popViewController()
        }
    
        asyncOperationFail()
        view.listOperationFail(with: errorMessage, isInnerFolder: isInnerFolder)
    }
    
    func startProgress() {
        startAsyncOperation()
    }
}
