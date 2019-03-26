//
//  SelectNameSelectNamePresenter.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SelectNamePresenter: BasePresenter, SelectNameModuleInput {
    weak var view: SelectNameViewInput!
    var interactor: SelectNameInteractorInput!
    var router: SelectNameRouterInput!    
    
    private(set) var allFilesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
        
    //MARK: - BasePresenter

    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: - SelectNameViewOutput

extension SelectNamePresenter: SelectNameViewOutput {
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
}

// MARK: - SelectNameInteractorOutput

extension SelectNamePresenter: SelectNameInteractorOutput {
    func startProgress() {
        startAsyncOperation()
    }
    
    func operationSuccess(operation: SelectNameScreenType, item: Item?, isSubFolder: Bool) {
        asyncOperationSuccess()
        switch operation {
        case .selectAlbumName:
            view.hideView()
        case .selectPlayListName:
            router.hideScreen()
        case .selectFolderName:
            view.hideView()
            if let item = item {
                router.moveToFolderPage(presenter: self, item: item, isSubFolder: isSubFolder)
            }
        }
    }
    
    func operationFailedWithError(errorMessage: String) {
        asyncOperationSuccess()
        UIApplication.showErrorAlert(message: errorMessage)
        view.setupInitialState()
    }
}

//MARK: - BaseFilesGreedModuleOutput

extension SelectNamePresenter: BaseFilesGreedModuleOutput {
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            allFilesViewType = type
            allFilesSortType = sortedType
        }
    }
}
