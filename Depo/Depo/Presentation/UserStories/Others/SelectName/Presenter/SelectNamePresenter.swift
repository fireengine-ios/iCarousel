//
//  SelectNameSelectNamePresenter.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SelectNamePresenter: BasePresenter, SelectNameModuleInput, SelectNameViewOutput, SelectNameInteractorOutput {

    weak var view: SelectNameViewInput!
    var interactor: SelectNameInteractorInput!
    var router: SelectNameRouterInput!

    
    //from view
    
    func viewIsReady() {

    }
    
    func getTitle() -> String {
        return interactor.getTitle()
    }
    
    func getNextButtonText() -> String {
        return interactor.getNextButtonText()
    }
    
    func getPlaceholderText() -> String {
        return interactor.getPlaceholderText()
    }
    
    func getTextForEmptyTextFieldAllert() -> String {
        return interactor.getTextForEmptyTextFieldAllert()
    }
    
    func onNextButton(name: String) {
        if name.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            interactor.onNextButton(name: name)
        } else {
            UIApplication.showErrorAlert(message: getTextForEmptyTextFieldAllert())
        }
    }
    
    //from interactor
    
    func startProgress() {
        startAsyncOperation()
    }
    
    func operationSucces(operation: SelectNameScreenType) {
        asyncOperationSucces()
        switch operation {
        case .selectAlbumName:
            view.hideView()
            break
        case .selectPlayListName:
            router.hideScreen()
            break
        case .selectFolderName:
            view.hideView()
            break
        }
    }
    
    func operationFaildWithError(errorMessage: String) {
        asyncOperationSucces()
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
