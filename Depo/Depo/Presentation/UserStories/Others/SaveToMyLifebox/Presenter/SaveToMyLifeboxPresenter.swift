//
//  SaveToMyLifeboxPresenter.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class SaveToMyLifeboxPresenter: BasePresenter, SaveToMyLifeboxModuleInput {
    var view: SaveToMyLifeboxViewInput!
    var interactor: SaveToMyLifeboxInteractorInput!
    var router: SaveToMyLifeboxRouterInput!
    
    override func outputView() -> Waiting? {
        return view
    }
    
}

extension SaveToMyLifeboxPresenter: SaveToMyLifeboxViewOutput {
    func onSelect(item: WrapData) {
        router.onSelect(item: item)
    }
    
    func viewIsReady() {
        interactor.getData()
    }
    
    func startProgress() {
        startAsyncOperation()
    }
    
    func operationFailedWithError(errorMessage: String) {
        asyncOperationFail(errorMessage: errorMessage)
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func saveToMyLifeboxSaveRoot() {
        interactor.saveToMyLifeboxSaveRoot()
    }
}

extension SaveToMyLifeboxPresenter: SaveToMyLifeboxInteractorOutput {
    func saveOperationSuccess() {
        asyncOperationSuccess()
    }
    
    func operationSuccess(with items: [SharedFileInfo]) {
        view.sharedItemsDidGet(items: items)
        asyncOperationSuccess()
    }
}
