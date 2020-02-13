//
//  UploadFilesSelectionUploadFilesSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionPresenter: BaseFilesGreedPresenter, UploadFilesSelectionModuleInput, UploadFilesSelectionViewOutput {

    var getOtherSelectedPhotos: LocalAlbumPresenter.PassBaseDataSourceItemsHandler?
    var saveSelectedPhotos: LocalAlbumPresenter.ReturnBaseDataSourceItemsHandler?

    init() {
        super.init(sortedRule: .timeDownWithoutSection)
    }

    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = UploadFilesSelectionDataSource()
        super.viewIsReady(collectionView: collectionView)
        dataSource.isHeaderless = true
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func updateThreeDotsButton() {
        super.updateThreeDotsButton()
        
        getOtherSelectedPhotos.map { dataSource.selectedItemsArray.formUnion($0()) }
        
        if dataSource.selectedItemsArray.isEmpty == false {
            dataSource.updateSelectionCount()
        }
        dataSource.setSelectionState(selectionState: true)
    }
    
    override func viewWillDisappear() {
        saveSelectedPhotos?(dataSource.selectedItemsArray)

        super.viewWillDisappear()
    }
    
    override func reloadData() {
        startAsyncOperation()
        interactor.getAllItems(sortBy: sortedRule)
        dataSource.isPaginationDidEnd = true
        dataSource.dropData()
        dataSource.reloadData()
        view?.stopRefresher()
    }
    
    func newLocalItemsReceived(newItems: [BaseDataSourceItem]) {
        guard let uploadDataSource = dataSource as? UploadFilesSelectionDataSource, newItems.isEmpty == false else {
            asyncOperationSuccess()
            return
        }
        uploadDataSource.appendNewLocalItems(newItems: newItems)
        asyncOperationSuccess()
    }
    
    override func onNextButton() {
        if dataSource.selectedItemsArray.isEmpty == false {
            startAsyncOperation()
            if let interactor = interactor as? UploadFilesSelectionInteractor,
                let dataSource = dataSource as? ArrayDataSourceForCollectionView {
                
                let items = dataSource.getSelectedItems() + (getOtherSelectedPhotos?() ?? [])
                interactor.addToUploadOnDemandItems(items: items)
            }
            
            dataSource.selectAll(isTrue: false)
        } else {
            UIApplication.showErrorAlert(message: TextConstants.uploadFilesNothingUploadError)
        }
    }
    
    override func uploadData(_ searchText: String! = nil) {
        debugLog("UploadFilesSelectionPresenter uploadData")

        debugPrint("upload uploadData presenter override")
    }
    
    override func getNextItems() {
        debugLog("UploadFilesSelectionPresenter getNextItems")

        debugPrint("upload getNextItems presenter override")
    }
    
    override func getContentWithSuccessEnd() {
        asyncOperationSuccess()
    }
}
    
//MARK: - UploadFilesSelectionInteractorOutput

extension UploadFilesSelectionPresenter: UploadFilesSelectionInteractorOutput {
    func networkOperationStopped() {
        debugLog("UploadFilesSelectionPresenter networkOperationStopped")
        
        asyncOperationSuccess()
    }
    
    func addToUploadStarted() {
        debugLog("UploadFilesSelectionPresenter addToUploadStarted")
        
        router.showBack()
    }
    
    func addToUploadSuccessed() {
        debugLog("UploadFilesSelectionPresenter addToUploadSuccessed")
        
        asyncOperationSuccess()
    }
    
    func addToUploadFailedWith(errorMessage: String) {
        debugLog("UploadFilesSelectionPresenter addToUploadFailedWithError: \(errorMessage)")
        
        asyncOperationFail(errorMessage: errorMessage)
    }
}
