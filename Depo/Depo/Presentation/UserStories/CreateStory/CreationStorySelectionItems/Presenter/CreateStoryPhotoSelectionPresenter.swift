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
        dataSource = PhotoSelectionDataSource()

        super.viewIsReady(collectionView: collectionView)
        
        dataSource.canReselect = false
        dataSource.maxSelectionCount = NumericConstants.maxNumberPhotosInStory
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.preferedCellReUseID = CollectionViewCellsIdsConstant.cellForStoryImage
    }
    
    override func isArrayDataSource() -> Bool {
        return true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        dataSource.updateSelectionCount()
    }
    
    override func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: true)
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        startEditing()
        super.onChangeSelectedItemsCount(selectedItemsCount: selectedItemsCount)
    }
    
    override func onMaxSelectionExeption() {
        let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
        UIApplication.showErrorAlert(message: text)
    }
    
    override func onNextButton() {
        guard  let story = photoStory else {
            return
        }
        let array = dataSource.getSelectedItems()
        if (array.count > 0) {
            guard let wrapArray = array as? [Item] else {
                return
            }
            story.storyPhotos = wrapArray
            
            if let rout = router as? CreateStorySelectionRouter {
                rout.goToSelectionOrderPhotosFor(story: story)
            }
        } else {
            UIApplication.showErrorAlert(message: TextConstants.createStoryNoSelectedPhotosError)
        }
    }
    
    func configurateWithPhotoStory(story: PhotoStory) {
        photoStory = story
    }
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        //DBDROP
        var content = [[BaseDataSourceItem]]()
        array.forEach { items in
            content.append(items.filter { $0.fileType == .image })
        }
        super.getContentWithSuccess(array: content)
    }
    
    override func getContentWithSuccessEnd() {
        if dataSource.allObjectIsEmpty(),
           var filters = interactor.originalFilesTypeFilter,
            !filters.contains(.favoriteStatus(.favorites)) {
            filters.remove(.localStatus(.nonLocal))
            filters.append(.localStatus(.local))
            interactor.originalFilesTypeFilter = filters
            dataSource.originalFilters = filters
            self.filters = filters
            dataSource.isPaginationDidEnd = true
        }

        super.getContentWithSuccessEnd()       
        
    }
    
    override func filesAppendedAndSorted() {
        if let dataSource = dataSource as? PhotoSelectionDataSource {
            dataSource.configurateWithArray(array: [dataSource.allMediaItems])
        }
        super.filesAppendedAndSorted()
    }
    
    private func startEditing() {
        dataSource.setSelectionState(selectionState: true)
    }
}
