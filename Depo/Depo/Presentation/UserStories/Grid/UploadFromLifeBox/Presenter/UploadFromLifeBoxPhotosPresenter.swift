//
//  UploadFromLifeBoxPhotosPresenter.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxPhotosPresenter: BaseFilesGreedPresenter, UploadFromLifeBoxInteractorOutput {

    private let storageVars: StorageVars = factory.resolve()
    
    override func viewIsReady(collectionView: UICollectionView) {
        //dataSource = PhotoSelectionDataSource()
        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func viewWillDisappear() {
        
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        //view.setTitle(title: "", subTitle: "")
    }
    
    override func onMaxSelectionExeption() {
        debugLog("UploadFromLifeBoxPhotosPresenter onMaxSelectionExeption")

        let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
        UIApplication.showErrorAlert(message: text)
    }
    
    override func onNextButton() {
        debugLog("UploadFromLifeBoxPhotosPresenter onNextButton")

        let array = dataSource.getSelectedItems()
        if array.isEmpty {
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
        debugLog("UploadFromLifeBoxPhotosPresenter getContentWithSuccess")

        //DBDROP
        super.getContentWithSuccess(array: array)
    }
    
    func uploadOperationSuccess() {
        debugLog("UploadFromLifeBoxPhotosPresenter uploadOperationSuccess")
        dataSource.setSelectionState(selectionState: false)
        self.storageVars.indexedAlbumUUIDs = []
        stopModeSelected()
        guard let uploadView = view as? UploadFromLifeBoxViewInput else {
            return
        }
        uploadView.hideView()
        
        if interactor is UploadFromLifeBoxFavoritesInteractor {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageAddedToFavoritesFromLifeBox)
        }
    }
    
    func asyncOperationFail(errorResponse: ErrorResponse) {
        asyncOperationFail(errorMessage: errorResponse.description)
    }
}
