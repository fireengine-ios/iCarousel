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
    var publicToken: String? = nil
    var item: WrapData?
    var isInnerFolder = false
    
    func getData() {
        isInnerFolder ? getSaveToMyLifeboxInnerFolder() : getSaveToMyLifebox()
    }
    
    private func getSaveToMyLifebox() {
        output.startProgress()
        SaveToMyLifeboxApiService().getSaveToMyLifebox(publicToken: publicToken ?? "", size: 100, page: 0, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                self.output.operationSuccess(with: items)
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
    
    private func getSaveToMyLifeboxInnerFolder() {
        guard let item = item, let tempListingURL = item.tempListingURL else { return }
        output.startProgress()
        
        SaveToMyLifeboxApiService().getSaveToMyLifeboxInnerFolder(tempListingURL: tempListingURL, size: 100, page: 0, sortBy: .lastModifiedDate, sortOrder: .asc) { result in
            switch result {
            case .success(let items):
                self.output.operationSuccess(with: items)
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
    
    func saveToMyLifeboxSaveRoot() {
        guard let publicToken = publicToken else { return }
        output.startProgress()
        
        SaveToMyLifeboxApiService().saveToMyLifeboxSaveRoot(publicToken: publicToken) { result in
            switch result {
            case .success():
                self.output.saveOperationSuccess()
            case .failed(let error):
                self.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
}
