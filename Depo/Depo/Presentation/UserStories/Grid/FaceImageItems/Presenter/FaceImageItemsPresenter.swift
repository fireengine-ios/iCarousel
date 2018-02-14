//
//  FaceImageItemsPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsPresenter: BaseFilesGreedPresenter {
    
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
        
        items.forEach { item in
            if isChangeVisibilityMode {
                visibilityItems.append(item)
            } else if let peopleItem = item as? PeopleItem,
                let isVisible = peopleItem.responseObject.visible
                {
                    if isVisible {
                        visibilityItems.append(item)
                    }
            } else {
                visibilityItems.append(item)
            }
        }
        
        super.getContentWithSuccess(items: visibilityItems)
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
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

// MARK: FaceImageItemsInteractorOutput

extension FaceImageItemsPresenter: FaceImageItemsInteractorOutput {
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item) {
        if let router = router as? FaceImageItemsRouter, let uuid = album.uuid, let coverPhotoURL = album.coverPhoto?.tempDownloadURL {
            router.openFaceImageItemPhotosWith(item, albumUUID: uuid, coverPhotoURL: coverPhotoURL, moduleOutput: self)
        }
    }
    
    func didSaveChanges(_ items: [PeopleItem]) {
        isChangeVisibilityMode = false
        dataSource.setSelectionState(selectionState: false)
        
        view.stopSelection()
        
        for item in allItmes {
            for changeItem in items {
                if (item.id == changeItem.id),
                    let peopleItem = item as? PeopleItem,
                    let isVisible = peopleItem.responseObject.visible
                {
                    peopleItem.responseObject.visible = !isVisible
                }
            }
        }
        
        getContentWithSuccess(items: allItmes)
    }
    
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsViewOutput {
    
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
    
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {
        allItmes.forEach {
            if $0.id == item.id {
                $0.name = item.name
                
                return
            }
        }
        
        getContentWithSuccess(items: allItmes)
    }
    
    func didMergePeople() {
        reloadData()
    }
    
}
