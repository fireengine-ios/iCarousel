//
//  UploadFilesSelectionUploadFilesSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionPresenter: BaseFilesGreedPresenter, UploadFilesSelectionModuleInput, UploadFilesSelectionViewOutput, UploadFilesSelectionInteractorOutput {
    
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
            asyncOperationSucces()
            return
        }
        uploadDataSource.appendNewLocalItems(newItems: newItems)
        asyncOperationSucces()
    }
    
    override func onNextButton() {
        if !dataSource.selectedItemsArray.isEmpty {
            startAsyncOperation()
            if let interactor_ = interactor as? UploadFilesSelectionInteractor, let dataSource = dataSource as? ArrayDataSourceForCollectionView {
                interactor_.addToUploadOnDemandItems(items: dataSource.getSelectedItems())
                router.showBack()
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
        asyncOperationSucces()
    }
    
    //MARK: - UploadFilesSelectionInteractorOutput
    
    func networkOperationStopped() {
        debugLog("UploadFilesSelectionPresenter networkOperationStopped")

        asyncOperationSucces()
    }
    
    func addToUploadSuccessed() {
        debugLog("UploadFilesSelectionPresenter addToUploadSuccessed")
        
        asyncOperationSucces()
        if let uploadVC = view as? UploadFilesSelectionViewInput {
            uploadVC.currentVC.navigationController?.viewControllers.first?.dismiss(animated: true)
            uploadVC.currentVC.navigationController?.popViewController(animated: true)
        }
    }
    
    func addToUploadFailedWith(errorMessage: String) {
        debugLog("UploadFilesSelectionPresenter addToUploadFailedWithError: \(errorMessage)")
        
        asyncOperationFail(errorMessage: errorMessage)
    }
    
}
