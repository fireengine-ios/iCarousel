//
//  UploadFilesSelectionUploadFilesSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionPresenter: BaseFilesGreedPresenter, UploadFilesSelectionModuleInput, UploadFilesSelectionViewOutput {

    init() {
        super.init(sortedRule: .timeDownWithoutSection)
    }

    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = UploadFilesSelectionDataSource()
        super.viewIsReady(collectionView: collectionView)
        dataSource.isHeaderless = true
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
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
        guard let uploadDataSource  = dataSource as? UploadFilesSelectionDataSource,
            !newItems.isEmpty else {
                asyncOperationSuccess()
            return
        }
        uploadDataSource.appendNewLocalItems(newItems: newItems)
        asyncOperationSuccess()
    }
    
    override func onNextButton() {
        if !dataSource.selectedItemsArray.isEmpty {
            startAsyncOperation()
            if let interactor_ = interactor as? UploadFilesSelectionInteractor, let dataSource = dataSource as? ArrayDataSourceForCollectionView {
                interactor_.addToUploadOnDemandItems(items: dataSource.getSelectedItems())
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
