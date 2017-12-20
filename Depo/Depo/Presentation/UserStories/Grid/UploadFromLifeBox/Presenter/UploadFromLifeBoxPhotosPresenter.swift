//
//  UploadFromLifeBoxPhotosPresenter.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxPhotosPresenter: BaseFilesGreedPresenter, UploadFromLifeBoxInteractorOutput {
    
    override func viewIsReady(collectionView: UICollectionView) {
        //dataSource = PhotoSelectionDataSource()
        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.preferedCellReUseID = CollectionViewCellsIdsConstant.cellForImage
        
    }
    
    override func viewWillDisappear() {
        
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int){
        //view.setTitle(title: "", subTitle: "")
    }
    
    override func onMaxSelectionExeption(){
        let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
        UIApplication.showErrorAlert(message: text)
    }
    
    override func onNextButton(){
        let array = dataSource.getSelectedItems()
        if array.isEmpty {
            UIApplication.showErrorAlert(message: TextConstants.uploadFromLifeBoxNoSelectedPhotosError)
        }else{
            guard let wrapArray = array as? [Item] else {
                return
            }
            if let uploadInteractor = interactor as? UploadFromLifeBoxInteractorInput{
                startAsyncOperation()
                uploadInteractor.onUploadItems(items: wrapArray)
            }
        }
    }
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]){
        //DBDROP
        super.getContentWithSuccess(array: array)
    }
    
    func uploadOperationSuccess(){
        guard let uploadView = view as? UploadFromLifeBoxViewInput else{
            return
        }
        uploadView.hideView()
    }
    
}

