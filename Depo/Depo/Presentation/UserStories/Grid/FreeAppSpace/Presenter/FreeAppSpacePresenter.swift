//
//  FreeAppSpaceFreeAppSpacePresenter.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpacePresenter: BaseFilesGreedPresenter {

    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.needShowCloudIcon = false
    }
    
    override func isArrayDataSource() -> Bool{
        return false
    }
    
    override func onNextButton() {
        if dataSource.selectedItemsArray.isEmpty {
            return
        }
        if let int = interactor as? FreeAppSpaceInteractor {
            if let array = dataSource.getSelectedItems() as? [WrapData] {
                startAsyncOperation()
                int.onDeleteSelectedItems(selectedItems: array)
            }
        }
        
    }
    
    func goBack(){
        if let router_ = router as? FreeAppSpaceRouter {
            router_.onBack()
        }
    }
    
    func onItemDeleted(){
        let count = dataSource.selectedItemsArray.count
        dataSource.selectedItemsArray.removeAll()
        dataSource.updateSelectionCount()
        
        let text = String(format: TextConstants.freeAppSpaceAlertSuccesTitle, count)
        UIApplication.showSuccessAlert(message: text)
    }
    
     override func moreActionsPressed(sender: Any) {
        let selectionMode = dataSource.isInSelectionMode()
        if selectionMode {
            let actionTypes = interactor.alerSheetMoreActionsConfig?.selectionModeTypes ?? []
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             items: selectedItems,
                                             presentedBy: sender,
                                             onSourceView: nil,
                                             excludeTypes: alertSheetExcludeTypes)
        } else {
            let actionTypes  = interactor.alerSheetMoreActionsConfig?.initialTypes ?? []
            alertSheetModule?.showAlertSheet(with: actionTypes,
                                             presentedBy: sender,
                                             onSourceView: nil)
        }
        
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
}

