//
//  FaceImageItemsPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsPresenter: BaseFilesGreedPresenter, FaceImageItemsInteractorOutput {
    
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
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    override func selectPressed(type: MoreActionsConfig.SelectedType) { }
    
    override func selectModeSelected() { }
    
    override func onLongPressInCell() { }
    
    // MARK: - Interactor Output
    
    func didLoadAlbum(_ albumUUID: String, forItem item: Item) {
        if let router = router as? FaceImageItemsRouter {
            router.openFaceImageItemPhotosWith(item, albumUUID: albumUUID)
        }
    }
}
