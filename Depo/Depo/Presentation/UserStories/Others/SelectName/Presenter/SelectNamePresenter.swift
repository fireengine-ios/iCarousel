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
    
    weak var selectNameModuleOutput: SelectNameModuleOutput?

    private(set) var allFilesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
        
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
        if name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            operationFailedWithError(errorMessage: getTextForEmptyTextFieldAllert())
        } else {
            interactor.onNextButton(name: name)
        }
    }
    
    //from interactor
    
    func startProgress() {
        startAsyncOperation()
    }
    
    func operationSuccess(operation: SelectNameScreenType, item: Item?, isSubFolder: Bool) {
        asyncOperationSuccess()
        switch operation {
        case .selectPlayListName:
            router.hideScreen()
        case .selectFolderName:
            view.hideView { [weak self] in
                guard let self = self, let item = item else {
                    return
                }
                self.router.moveToFolderPage(presenter: self, item: item, isSubFolder: isSubFolder)
            }
        default: 
            break
        }
    }
    
    func createAlbumOperationSuccess(item: AlbumItem?) {
        asyncOperationSuccess()
        view.hideView { [weak  self] in
            guard let  self = self, let item = item else {
                return
            }
            
            if self.selectNameModuleOutput != nil {
                self.selectNameModuleOutput?.didCreateAlbum(item: item)
            } else {
                self.router.moveToAlbumPage(presenter: self, item: item)
            }
        }
    }
    
    func operationFailedWithError(errorMessage: String) {
        asyncOperationSuccess()
        UIApplication.showErrorAlert(message: errorMessage)
        view.setupInitialState()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

//MARK : BaseFilesGreedModuleOutput

extension SelectNamePresenter: BaseFilesGreedModuleOutput {
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            allFilesViewType = type
            allFilesSortType = sortedType
        }
    }
}
