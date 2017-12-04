//
//  UploadFromLifeBoxUploadFromLifeBoxPresenter.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxPresenter: BaseFilesGreedPresenter, UploadFromLifeBoxInteractorOutput {
    
    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = PhotoSelectionDataSource()
        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.canReselect = true
        dataSource.maxSelectionCount = NumericConstants.maxNumberPhotosInStory
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.preferedCellReUseID = CollectionViewCellsIdsConstant.cellForStoryImage
    }
    
    override func isArrayDataSource() -> Bool{
        return true
    }
    
    override func viewWillDisappear() {
        
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int){
        //view.setTitle(title: "", subTitle: "")
    }
    
    override func onMaxSelectionExeption(){
        let custoPopUp = CustomPopUp.sharedInstance
        let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
        custoPopUp.showCustomAlert(withText: text, okButtonText: TextConstants.createStoryPhotosMaxCountAllertOK)
    }
    
    override func onNextButton(){
        let array = dataSource.getSelectedItems()
        if (array.count > 0){
            guard let wrapArray = array as? [Item] else {
                return
            }
            if let uploadInteractor = interactor as? UploadFromLifeBoxInteractorInput{
                uploadInteractor
            }
        }else{
            custoPopUp.showCustomAlert(withText: TextConstants.uploadFromLifeBoxNoSelectedPhotosError, okButtonText: TextConstants.uploadFromLifeBoxEmptyFolderButtonText)
        }
    }
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]){
        //DBDROP
        super.getContentWithSuccess(array: array)
    }
}
