//
//  UploadFilesSelectionUploadFilesSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionPresenter: BaseFilesGreedPresenter, UploadFilesSelectionModuleInput, UploadFilesSelectionViewOutput, UploadFilesSelectionInteractorOutput {
    
    override func viewIsReady(collectionView: UICollectionView) {
        
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func onNextButton(){
        if (dataSource.selectedItemsArray.count > 0){
            startAsyncOperation()
            if let interactor_ = interactor as? UploadFilesSelectionInteractor{
                //!!!!!!!!!!!!!
                //interactor_.uploadItems(items: Array(dataSource.selectedItemsArray))
                let list = Array(dataSource.selectedItemsArray)
                let array = CoreDataStack.default.mediaItemByUUIDs(uuidList: list)
                interactor_.uploadItems(items: array)
            }
        }else{
            custoPopUp.showCustomAlert(withText: TextConstants.uploadFilesNothingUploadError, okButtonText: TextConstants.uploadFilesNothingUploadOk)
        }
    }
    
    func networkOperationStopped(){
        asyncOperationSucces()
    }
    
}
