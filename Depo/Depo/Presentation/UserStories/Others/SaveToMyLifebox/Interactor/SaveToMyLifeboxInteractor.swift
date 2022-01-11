//
//  SaveToMyLifeboxInteractor.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class SaveToMyLifeboxInteractor: SaveToMyLifeboxInteractorInput {
    var output: SaveToMyLifeboxInteractorOutput!
    var publicToken: String?
    var item: WrapData?
    var isInnerFolder = false
    
    func fetchData(at page: Int) {
        isInnerFolder ? getSaveToMyLifeboxInnerFolder(for: page) : getSaveToMyLifebox(for: page)
    }
    
    private func getSaveToMyLifebox(for page: Int) {
        output.startProgress()
        SaveToMyLifeboxApiService().getSaveToMyLifebox(publicToken: publicToken ?? "", size: 20, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.output.operationSuccessFinish()
                } else {
                    self.output.operationSuccess(with: items)
                }
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
    
    private func getSaveToMyLifeboxInnerFolder(for page: Int) {
        guard let item = item, let tempListingURL = item.tempListingURL else { return }
        output.startProgress()
        
        SaveToMyLifeboxApiService().getSaveToMyLifeboxInnerFolder(tempListingURL: tempListingURL, size: 20, page: page, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.output.operationSuccessFinish()
                } else {
                    self.output.operationSuccess(with: items)
                }
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
    
    func saveToMyLifeboxSaveRoot() {
        output.startProgress()
        
        SaveToMyLifeboxApiService().saveToMyLifeboxSaveRoot(publicToken: publicToken ?? "") { result in
            switch result {
            case .success():
                self.output.saveOperationSuccess()
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
}
