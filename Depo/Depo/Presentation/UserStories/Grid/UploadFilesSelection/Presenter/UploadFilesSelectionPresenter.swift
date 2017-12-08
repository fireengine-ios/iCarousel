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
        interactor.getAllItems(sortBy: sortedRule)
        asyncOperationSucces()
        dataSource.isPaginationDidEnd = true
        dataSource.dropData()
        dataSource.reloadData()
        view?.stopRefresher()
    }
    
    override func onNextButton(){
        if (dataSource.selectedItemsArray.count > 0){
            startAsyncOperation()
            if let interactor_ = interactor as? UploadFilesSelectionInteractor, let dataSource = dataSource as? ArrayDataSourceForCollectionView {

                interactor_.addToUploadOnDemandItems(items: dataSource.getSelectedItems())
                guard let uploadVC = view as? UploadFilesSelectionViewInput else {
                    return
                }
                
                uploadVC.currentVC.navigationController?.viewControllers.first?.dismiss(animated: true)
                uploadVC.currentVC.navigationController?.popViewController(animated: true)
            }
        } else {
            custoPopUp.showCustomAlert(withText: TextConstants.uploadFilesNothingUploadError, okButtonText: TextConstants.uploadFilesNothingUploadOk)
        }
    }
    
    override func uploadData(_ searchText: String! = nil) {
        debugPrint("upload uploadData presenter override")
    }
    
    override func getNextItems() {
        debugPrint("upload getNextItems presenter override")
    }
    
    override func getContentWithSuccessEnd() {
        
    }
    
    func networkOperationStopped(){
        asyncOperationSucces()
    }

    override func onLongPressInCell() {}
    
}
