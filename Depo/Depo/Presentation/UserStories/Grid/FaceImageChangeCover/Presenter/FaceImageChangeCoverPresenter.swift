//
//  FaceImageChangeCoverPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageChangeCoverPresenter: BaseFilesGreedPresenter {
    
    weak var customModuleOutput: FaceImageChangeCoverModuleOutput?
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.isHeaderless = true
        dataSource.canSelectionState = false
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageChangeCoverInteractor {
            interactor.setAlbumCoverWithItem(item)
        }
    }
    
    override func onReloadData() {
        getContentWithSuccess(items: [])
    }
    
    override func selectPressed(type: MoreActionsConfig.SelectedType) { }
    
    override func selectModeSelected() { }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
}

// MARK: - FaceImageChangeCoverInteractorOutput

extension FaceImageChangeCoverPresenter: FaceImageChangeCoverInteractorOutput {
    
    func didSetCover(item: BaseDataSourceItem) {
        if let router = router as? FaceImageChangeCoverRouterInput {
            router.back()
        }
        
        if let item = item as? WrapData {
            customModuleOutput?.onAlbumCoverSelected(item: item)
        }
    }
    
}
