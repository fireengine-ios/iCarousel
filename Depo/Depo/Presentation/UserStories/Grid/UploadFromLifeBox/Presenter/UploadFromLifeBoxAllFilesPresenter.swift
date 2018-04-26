//
//  UploadFromLifeBoxUploadFromLifeBoxPresenter.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxAllFilesPresenter: DocumentsGreedPresenter, UploadFromLifeBoxInteractorOutput {
    
    override func viewIsReady(collectionView: UICollectionView) {
        //dataSource = PhotoSelectionDataSource()
        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: false)
        dataSource.needShow3DotsInCell = false
        dataSource.updateDisplayngType(type: .greed)
        dataSource.preferedCellReUseID = CollectionViewCellsIdsConstant.baseMultiFileCell
        
    }
    
    override func viewWillDisappear() {
        
    }
    
    override func onMaxSelectionExeption() {
        log.debug("UploadFromLifeBoxPhotosPresenter onMaxSelectionExeption")

        let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
        UIApplication.showErrorAlert(message: text)
    }
    
    override func onNextButton() {
        log.debug("UploadFromLifeBoxPhotosPresenter onNextButton")

        let array = dataSource.getSelectedItems()
        if (array.isEmpty) {
            UIApplication.showErrorAlert(message: TextConstants.uploadFromLifeBoxNoSelectedPhotosError)
        } else {
            guard let wrapArray = array as? [Item] else {
                return
            }
            if let uploadInteractor = interactor as? UploadFromLifeBoxInteractorInput {
                startAsyncOperation()
                uploadInteractor.onUploadItems(items: wrapArray)
            }
        }
    }
    
    override func getContentWithSuccess(array: [[BaseDataSourceItem]]) {
        super.getContentWithSuccess(array: array)
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        if let interactor = interactor as? UploadFromLifeBoxInteractor {
            let filtredArray = items.filter({
                $0.uuid != interactor.rootFolderUUID
            })
            super.getContentWithSuccess(items: filtredArray)
        } else {
            super.getContentWithSuccess(items: items)
        }
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        log.debug("UploadFromLifeBoxPhotosPresenter onItemSelected")

        guard let wrapDataItem = item as? WrapData, let isFolder = wrapDataItem.isFolder else {
            super.onItemSelected(item: item, from: data)
            return
        }
        if !dataSource.isInSelectionMode() && isFolder {
            guard let uploadView = view as? UploadFromLifeBoxViewInput,
                let nController = uploadView.getNavigationController(),
                let uploadRouter = router as? UploadFromLifeBoxRouterInput else {
                return
            }
            uploadRouter.goToFolder(destinationFolderUUID: uploadView.getDestinationUUID(), outputFolderUUID: wrapDataItem.uuid, nController: nController)
        }
    }
    
    func uploadOperationSuccess() {
        log.debug("UploadFromLifeBoxPhotosPresenter uploadOperationSuccess")
        dataSource.setSelectionState(selectionState: false)
        stopModeSelected()
        guard let uploadView = view as? UploadFromLifeBoxViewInput else {
            return
        }
        uploadView.hideView()
    }
    
    override func asyncOperationFail(errorResponse: ErrorResponse) {
        if errorResponse.isOutOfSpaceError {
            asyncOperationSucces()
            dataSource.setSelectionState(selectionState: false)
            stopModeSelected()
            guard let uploadView = view as? UploadFromLifeBoxViewInput else {
                return
            }
            uploadView.showOutOfSpaceAlert()
        } else {
            asyncOperationFail(errorMessage: errorResponse.description)
        }
    }
}
