//
//  PublicShareInteractor.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class PublicShareInteractor: PublicShareInteractorInput {
    var output: PublicShareInteractorOutput!
    var publicToken: String?
    var item: WrapData?
    var isInnerFolder = false
    
    private var page: Int = 0
    private var isLastPage: Bool = false
        
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
        PublicSharedItemsService().getPublicSharedItemsList(publicToken: publicToken ?? "", size: 40, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.isLastPage = true
                }
                self.output.listOperationSuccess(with: items)
            case .failed(let error):
                self.output.listOperationFail(errorMessage: error.description, isInnerFolder: false)
            }
        }
    }
    
    private func getPublicSharedItemsInnerFolder() {
        guard let item = item, let tempListingURL = item.tempListingURL else { return }
        output.startProgress()
        
        PublicSharedItemsService().getPublicSharedItemsInnerFolder(tempListingURL: tempListingURL, size: 40, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.isLastPage = true
                }
                self.output.listOperationSuccess(with: items)
            case .failed(let error):
                self.output.listOperationFail(errorMessage: error.description, isInnerFolder: true)
            }
        }
    }
    
    func savePublicSharedItems() {
        output.startProgress()

        PublicSharedItemsService().savePublicSharedItems(publicToken: publicToken ?? "") { value in
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
}
