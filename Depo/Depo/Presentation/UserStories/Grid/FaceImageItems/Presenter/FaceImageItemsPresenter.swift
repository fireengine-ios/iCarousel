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
        allItmes = []
        
        items.forEach { item in
            guard item.urlToFile != nil else { return }

            if isChangeVisibilityMode {
                allItmes.append(item)
            } else if let peopleItem = item as? PeopleItem,
                let isVisible = peopleItem.responseObject.visible {
                if isVisible { allItmes.append(item) }
            } else {
                allItmes.append(item)
            }
        }
        
        super.getContentWithSuccess(items: allItmes)
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    // MARK: -  Utility methods
    
    private func switchVisibilityMode(_ isChangeVisibilityMode: Bool) {
        self.isChangeVisibilityMode = isChangeVisibilityMode
        dataSource.setSelectionState(selectionState: isChangeVisibilityMode)
        reloadData()
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
        if let router = router as? FaceImageItemsRouter {
            let albumItem = AlbumItem(remote: album)
            router.openFaceImageItemPhotosWith(item, album: albumItem, moduleOutput: self)
        }
    }
    
    func didSaveChanges(_ items: [PeopleItem]) {
        isChangeVisibilityMode = false
        dataSource.setSelectionState(selectionState: false)
        
        view.stopSelection()
        
        reloadData()
    }
    
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsViewOutput {
    
    func switchVisibilityMode() {
        switchVisibilityMode(!isChangeVisibilityMode)
    }
    
    func saveVisibilityChanges() {
        if let interactor = interactor as? FaceImageItemsInteractor,
            !selectedItems.isEmpty {
            
            let peopleItems = selectedItems.flatMap { $0 as? PeopleItem }
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
        reloadData()
    }
    
    func didReloadData() {
        reloadData()
    }
    
}
