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
    private let analyticsService: AnalyticsService = factory.resolve()
    
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
        
        publicShareService.getPublicSharedItemsList(publicToken: publicToken ?? "", size: itemCount, page: 0, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                self.output.listAllItemsSuccess(with: items)
                let fileTypes = self.createDownloadGAEventLabel(with: items)
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .download, eventLabel: .custom(fileTypes))
            case .failed(_):
                self.output.listAllItemsFail(errorMessage: localized(.publicShareFileNotFoundError), isToastMessage: true)
            }
        }
    }
    
    private func createDownloadGAEventLabel(with items: [SharedFileInfo]) -> String {
        let types: [String] = items.map {
            switch $0.fileType {
            case .image, .photoAlbum, .faceImage, .faceImageAlbum, .imageAndVideo:
                return "Photo"
            case .video:
                return "Video"
            case .audio:
                return "Audio"
            case .allDocs, .application:
                return "Document"
            case .musicPlayList:
                return "Music"
            case .folder, .unknown:
                return "File"
            }
        }
        
        return Set(types).joined(separator: "-")
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
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .saveToMyLifebox, eventLabel: .success)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLSavetomylifebox1(status: .success))
        } fail: { error in
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .saveToMyLifebox, eventLabel: .failure)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLSavetomylifebox1(status: .failure))
            
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
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .failure))
                self.output.createDownloadLinkFail()
            }
        }
    }
    
    func downloadPublicSharedItems(with url: String) {
        guard let url = URL(string: url) else { return }
        
        downloader.delegate = self
        downloader.startDownload(url: url, fileName: fileName)
    }
    
    func trackPublicShareScreen() {
        analyticsService.logScreen(screen: .saveToMyLifebox)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.STLSavetomylifeboxScreen())
    }
    
    func trackSaveToMyLifeboxClick() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .saveToMyLifebox)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLSavetomylifebox())
    }
    
    func trackDownloadSuccess() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .success))
    }
    
    func trackDownloadCancel() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .cancel))
    }
}

extension PublicShareInteractor: PublicShareDownloaderDelegate {
    func publicShareDownloadCompleted(isSuccess: Bool, url: URL?) {
        if isSuccess, let url = url {
            output.downloadOperationSuccess(with: url)
        } else {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .failure))
            output.downloadOperationFailed()
        }
    }
    
    func publicShareDownloadContinue(downloadedByte: String) {
        output.downloadOperationContinue(downloadedByte: downloadedByte)
    }
    
    func publicShareDownloadCancelled() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .cancel))
    }
    
    func publicShareDownloadNotEnoughSpace() {
        output.downloadOperationStorageFail()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.STLDownload(status: .failure))
    }
}
