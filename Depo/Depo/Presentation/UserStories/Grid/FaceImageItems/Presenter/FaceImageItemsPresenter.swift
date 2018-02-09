//
//  FaceImageItemsPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsPresenter: BaseFilesGreedPresenter, FaceImageItemsInteractorOutput, FaceImageItemsViewOutput, FaceImageItemsModuleOutput {
    
    private var isChangeVisibilityMode: Bool = false
    
    private var visibilityItems: [WrapData] = []
    private var allItmes: [WrapData] = []
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImage)
        dataSource.isHeaderless = true
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageItemsInteractor {
            interactor.loadItem(item)
        }
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        allItmes = items
        
        clearItems()
        
        items.forEach {
            if isChangeVisibilityMode {
                visibilityItems.append($0)
            } else {
                if let peopleItem = $0 as? PeopleItem,
                    let isVisible = peopleItem.responseObject.visible
                    {
                        if isVisible {
                            visibilityItems.append($0)
                        }
                } else {
                    visibilityItems.append($0)
                }
            }
        }
        
        super.getContentWithSuccess(items: visibilityItems)
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    // MARK: - Interactor Output
    
    func didLoadAlbum(_ albumUUID: String, forItem item: Item) {
        if let router = router as? FaceImageItemsRouter {
            router.openFaceImageItemPhotosWith(item, albumUUID: albumUUID, moduleOutput: self)
        }
    }
    
    func didSaveChanges(_ items: [PeopleItem]) {
        isChangeVisibilityMode = false
        dataSource.setSelectionState(selectionState: false)
        
        view.stopSelection()
        
        allItmes.forEach { (item) in
            items.forEach({
                if (item.id == $0.id) {
                    if let peopleItem = item as? PeopleItem,
                        let isVisible = peopleItem.responseObject.visible
                    {
                        peopleItem.responseObject.visible = !isVisible
                    }
                }
            })
        }
        
        getContentWithSuccess(items: allItmes)
    }
    
    // MARK: - FaceImageItemsViewOutput
    
    func switchVisibilityMode() {
        switchVisibilityMode(!isChangeVisibilityMode)
    }
    
    func saveVisibilityChanges() {
        if let interactor = interactor as? FaceImageItemsInteractor,
            selectedItems.count > 0 {
            var peopleItems: [PeopleItem] = []
            selectedItems.forEach({
                if let item = $0 as? PeopleItem {
                    peopleItems.append(item)
                }
            })
            
            interactor.onSaveVisibilityChanges(peopleItems)
        } else {
            view.stopSelection()
            
            switchVisibilityMode(!isChangeVisibilityMode)
        }
    }
    
    // MARK: - FaceImageItemsModuleOutput
    
    func didChangeName(item: WrapData) {
        allItmes.forEach {
            if $0.id == item.id {
                $0.name = item.name
            }
        }
        
        getContentWithSuccess(items: allItmes)
    }
    
    func didMergePeople() {
        reloadData()
    }
    
    // MARK: -  Utility methods
    
    private func switchVisibilityMode(_ isChangeVisibilityMode: Bool) {
        self.isChangeVisibilityMode = isChangeVisibilityMode
        
        dataSource.setSelectionState(selectionState: isChangeVisibilityMode)
        
        getContentWithSuccess(items: allItmes)
    }
    
    private func clearItems() {
        visibilityItems = [WrapData]()
        dataSource.allMediaItems = [WrapData]()
        dataSource.allItems = [[WrapData]]()
    }
    
}
