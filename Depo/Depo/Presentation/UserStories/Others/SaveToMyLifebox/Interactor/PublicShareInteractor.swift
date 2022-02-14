//
//  PublicShareInteractor.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareInteractor: NSObject, PublicShareInteractorInput {
    var output: PublicShareInteractorOutput!
    var publicToken: String?
    var item: WrapData?
    var isInnerFolder = false
    
    private var fileName: String = ""
    private var page: Int = 0
    private var isLastPage: Bool = false
    private let publicShareService = PublicSharedItemsService()
    private let downloader = PublicShareDownloader.shared
        
    func fetchData() {
        isInnerFolder ? getPublicSharedItemsInnerFolder() : getPublicSharedItemsList()
    }
    
    func fetchMoreIfNeeded() {
        if !isLastPage {
            page += 1
            isInnerFolder ? getPublicSharedItemsInnerFolder() : getPublicSharedItemsList()
        }
    }
    
    private func getPublicSharedItemsList() {
        output.startProgress()
        
        publicShareService.getPublicSharedItemsList(publicToken: publicToken ?? "", size: 40, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.isLastPage = true
                }
                self.output.listOperationSuccess(with: items)
            case .failed(let error):
                self.output.listOperationFail(errorMessage: error.description, isToastMessage: false)
            }
        }
    }
    
    private func getPublicSharedItemsInnerFolder() {
        guard let item = item, let tempListingURL = item.tempListingURL else { return }
        output.startProgress()
        
        publicShareService.getPublicSharedItemsInnerFolder(tempListingURL: tempListingURL, size: 40, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.isLastPage = true
                }
                self.output.listOperationSuccess(with: items)
            case .failed(let error):
                self.output.listOperationFail(errorMessage: error.description, isToastMessage: true)
            }
        }
    }
    
    func getAllPublicSharedItems(with itemCount: Int, fileName: String) {
        self.fileName = fileName
        output.startProgress()
        
        publicShareService.getPublicSharedItemsList(publicToken: publicToken ?? "", size: itemCount, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                self.output.listAllItemsSuccess(with: items)
            case .failed(_):
                self.output.listAllItemsFail(errorMessage: localized(.publicShareFileNotFoundError), isToastMessage: true)
            }
        }
    }
    
    func getPublicSharedItemsCount() {
        output.startProgress()
        
        publicShareService.getPublicSharedItemsCount(publicToken: publicToken ?? "") { result in
            switch result {
            case .success(let count):
                if let itemCount = Int(count) {
                    self.output.countOperationSuccess(with: itemCount)
                }
            case .failed(_):
                self.output.countOperationFail()
            }
        }
    }
    
    func savePublicSharedItems() {
        output.startProgress()

        publicShareService.savePublicSharedItems(publicToken: publicToken ?? "") { value in
            self.output.saveOperationSuccess()
            ItemOperationManager.default.publicShareItemsAdded()
        } fail: { error in
            if error.errorDescription == PublicShareSaveErrorStatus.notRequiredSpace.rawValue {
                self.output.saveOperationStorageFail()
                return
            }
            let message = PublicShareSaveErrorStatus.allCases.first(where: {$0.rawValue == error.errorDescription})?.description
            self.output.saveOperationFail(errorMessage: message ?? localized(.publicShareSaveError))
        }
    }
    
    func createPublicShareDownloadLink(with uuid: [String]) {
        output.startProgress()
    
        publicShareService.createPublicShareDownloadLink(publicToken: publicToken ?? "", uuid: uuid) { result in
            switch result {
            case .success(let url):
                self.output.createDownloadLinkSuccess(with: url)
            case .failed(_):
                self.output.createDownloadLinkFail()
            }
        }
    }
    
    func downloadPublicSharedItems(with url: String) {
        guard let url = URL(string: url) else { return }
        
        downloader.delegate = self
        downloader.startDownload(url: url, fileName: fileName)
    }
}

extension PublicShareInteractor: PublicShareDownloaderDelegate {
    func publicShareDownloadCompleted(isSuccess: Bool, url: URL?) {
        if isSuccess, let url = url {
            output.downloadOperationSuccess(with: url)
        } else {
            output.downloadOperationFailed()
        }
    }
    
    func publicShareDownloadContinue(downloadedByte: String) {
        output.downloadOperationContinue(downloadedByte: downloadedByte)
    }
}
