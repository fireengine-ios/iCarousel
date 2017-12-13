//
//  FreeAppSpaceFreeAppSpacePresenter.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpacePresenter: BaseFilesGreedPresenter, CustomPopUpAlertActions{
    
    let customPopUp = CustomPopUp()

    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = ArrayDataSourceForCollectionView()
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func isArrayDataSource() -> Bool{
        return true
    }
    
    override func onNextButton() {
        if (dataSource.selectedItemsArray.count == 0){
            return
        }
//        customPopUp.delegate = self
//        let titleSting = String(format: TextConstants.freeAppSpaceAlertTitle, dataSource.selectedItemsArray.count)
//        customPopUp.showCustomAlert(withTitle: titleSting,
//                                    withText: TextConstants.freeAppSpaceAlertText,
//                                    firstButtonText: TextConstants.freeAppSpaceAlertCancel,
//                                    secondButtonText: TextConstants.freeAppSpaceAlertDelete)
        
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
        
        
        let titleSting = String(format: TextConstants.freeAppSpaceAlertSuccesTitle, count)
        CustomPopUp.sharedInstance.showCustomSuccessAlert(withTitle: "", withText: titleSting, okButtonText: TextConstants.freeAppSpaceAlertSuccesButton)
    }
    
    //MARK: - CustomPopUpAlertActions
    
    func cancelationAction() {
        
    }
    
    func otherAction() {
        
    }
    
}

