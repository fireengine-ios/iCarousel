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
    var itemCount: Int?
    var fileName: String?
    
    override func outputView() -> Waiting? {
        return view
    }
    
}

extension PublicSharePresenter: PublicShareViewOutput {    
    func fetchMoreIfNeeded() {
        interactor.fetchMoreIfNeeded()
    }
    
    func onSelect(item: WrapData) {
        router.onSelect(item: item, itemCount: itemCount ?? 0)
    }
    
    func onSelect(item: WrapData, items: [WrapData]) {
        router.onSelect(item: item, items: items)
    }
    
    func viewIsReady() {
        interactor.trackPublicShareScreen()
        interactor.fetchData()
    }
    
    func getPublicSharedItemsCount() {
        interactor.getPublicSharedItemsCount()
    }
    
    func onSaveButton(isLoggedIn: Bool) {
        interactor.trackSaveToMyLifeboxClick()
        isLoggedIn ? interactor.savePublicSharedItems() : router.navigateToOnboarding()
    }
    
    func onSaveDownloadButton(with fileName: String) {
        interactor.getAllPublicSharedItems(with: itemCount ?? 0, fileName: fileName)
    }
}

extension PublicSharePresenter: PublicShareInteractorOutput {
    func downloadOperationFailed() {
        view.downloadOperationFailed()
        router.showDownloadCompletePopup(isSuccess: false, message: "İndirme tamamlanamadı")
    }
    
    func downloadOperationContinue(downloadedByte: String) {
        view.downloadOperationContinue(downloadedByte: downloadedByte)
    }
    
    func downloadOperationSuccess(with url: URL) {
        view.downloadOperationSuccess()
        router.openFilesToSave(with: url)
    }
    
    func createDownloadLinkSuccess(with url: String) {
        asyncOperationSuccess()
        interactor.downloadPublicSharedItems(with: url)
    }
    
    func createDownloadLinkFail() {
        asyncOperationFail()
        view.createDownloadLinkFail()
    }
    
    func countOperationSuccess(with itemCount: Int) {
        asyncOperationSuccess()
        self.itemCount = itemCount
    }
    
    func countOperationFail() {
        asyncOperationFail(errorMessage: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
    
    func listAllItemsSuccess(with items: [SharedFileInfo]) {
        asyncOperationSuccess()
        let uuidList = items.compactMap {$0.uuid}
        interactor.createPublicShareDownloadLink(with: uuidList)
    }
    
    func listAllItemsFail(errorMessage: String, isToastMessage: Bool) {
        asyncOperationFail()
        view.listOperationFail(with: errorMessage, isToastMessage: isToastMessage)
    }
    
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
    
    func listOperationFail(errorMessage: String, isToastMessage: Bool) {
        if isToastMessage {
            router.popViewController()
        }
    
        asyncOperationFail()
        view.listOperationFail(with: errorMessage, isToastMessage: isToastMessage)
    }
    
    func startProgress() {
        startAsyncOperation()
    }
}
