//
//  CreateStoryPhotoSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotoSelectionPresenter: BaseFilesGreedPresenter, CreateStorySelectionInteractorOutput {

    var photoStory: PhotoStory?
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.maxSelectionCount = NumericConstants.maxNumberPhotosInStory
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.preferedCellReUseID = CollectionViewCellsIdsConstant.cellForStoryImage
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
        guard  let story = photoStory else {
            return
        }
        let array = dataSource.getSelectedItems()
        if (array.count > 0){
            guard let wrapArray = array as? [Item] else {
                return
            }
            story.storyPhotos = wrapArray
            
            if let rout = router as? CreateStorySelectionRouter{
                rout.goToSelectionOrderPhotosFor(story: story)
            }
        }else{
            custoPopUp.showCustomAlert(withText: TextConstants.createStoryNoSelectedPhotosError, okButtonText: TextConstants.createFolderEmptyFolderButtonText)
        }
    }
    
    func configurateWithPhotoStory(story: PhotoStory){
        photoStory = story
    }
    
    func getContentWithSuccess(array: [[WrapData]]){
        super.getContentWithSuccess()
    }
}
