//
//  FaceImageChangeCoverPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageChangeCoverPresenter: BaseFilesGreedPresenter, FaceImageChangeCoverInteractorOutput {
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.isHeaderless = true
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageChangeCoverInteractor {
            interactor.setAlbumCoverWithPhoto(item.uuid)
        }
    }
    
    override func selectPressed(type: MoreActionsConfig.SelectedType) {
    }
    
    override func selectModeSelected() {
    }
    
    override func onLongPressInCell() {
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        
    }

    func didSetCover() {
        if let router = router as? FaceImageChangeCoverRouterInput {
            router.back()
        }
    }
    
}
