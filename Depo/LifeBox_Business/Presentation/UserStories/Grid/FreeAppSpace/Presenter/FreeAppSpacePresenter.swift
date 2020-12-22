//
//  FreeAppSpaceFreeAppSpacePresenter.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpacePresenter: BaseFilesGreedPresenter {

    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
        dataSource.needShowCloudIcon = false
    }
    
    //Need override because freeAppSpace should not receive notifications about operations on files. Behaviour as on Android
    override func subscribeDataSource() {
        
    }
    
    override func isArrayDataSource() -> Bool {
        return false
    }
    
    override func onNextButton() {
        if dataSource.selectedItemsArray.isEmpty {
            return
        }
        if let int = interactor as? FreeAppSpaceInteractor {
            if let array = dataSource.getSelectedItems() as? [WrapData] {
                startAsyncOperation()
                if let view = view as? BaseFilesGreedViewController {
                    view.requestStarted()
                }
                int.onDeleteSelectedItems(selectedItems: array)
            }
        }
        
    }
    
    func goBack() {
        if let router_ = router as? FreeAppSpaceRouter {
            router_.onBack()
        }
    }
    override func reloadData() {
        super.reloadData()
        dataSource.selectedItemsArray.removeAll()
        dataSource.updateSelectionCount()
        if let view = view as? BaseFilesGreedViewController {
            view.requestStopped()
        }
    }
    
    func canceled() {
        asyncOperationSuccess()
        if let view = view as? BaseFilesGreedViewController {
            view.requestStopped()
        }
    }
    
    func onItemDeleted(count: Int) {
        if count > 0 {
            let text = String(format: TextConstants.freeAppSpaceAlertSuccesTitle, count)
            UIApplication.showSuccessAlert(message: text)
        }
        
        if let view = view as? BaseFilesGreedViewController {
            view.requestStopped()
        }
    }
    
     override func moreActionsPressed(sender: Any) {
        let selectionMode = dataSource.isInSelectionMode()
        if selectionMode {
            var actionTypes = interactor.alerSheetMoreActionsConfig?.selectionModeTypes ?? []
                
            if dataSource.allMediaItems.count == dataSource.selectedItemsArray.count {
                if let index = actionTypes.index(of: .selectAll) {
                    actionTypes.remove(at: index)
                    actionTypes.insert(.deSelectAll, at: index)
                }
            }
            
            alertSheetModule?.onlyPresentAlertSheet(with: actionTypes, for: [Item](), sender: sender)
        } else {
            let actionTypes = interactor.alerSheetMoreActionsConfig?.initialTypes ?? []

            alertSheetModule?.onlyPresentAlertSheet(with: actionTypes, for: [Item](), sender: sender)
        }
        
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        if let view = view as? FreeAppSpaceViewController {
            view.setTitleLabelText(duplicatesCount: items.count)
        }
        super.getContentWithSuccess(items: items)
    }

    override func stopSelectionWhenDisappear() {
        // we should not stop selection for FreeUpSpace screen so don't call 'super' logic
    }
}
