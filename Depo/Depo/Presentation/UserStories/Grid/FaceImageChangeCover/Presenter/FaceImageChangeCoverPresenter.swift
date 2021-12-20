//
//  FaceImageChangeCoverPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum CoverType {
    case albumCover
    case thumbnail
}

final class FaceImageChangeCoverPresenter: BaseFilesGreedPresenter {
    
    weak var customModuleOutput: FaceImageChangeCoverModuleOutput?
    var coverType: CoverType?
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.isHeaderless = true
        dataSource.canSelectionState = false
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageChangeCoverInteractor {
            if coverType == .thumbnail {
                interactor.setPersonThumbnailWith(item: item)
            } else {
                interactor.setAlbumCoverWithItem(item)
            }
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
    func didSetPersonThumbnail(item: BaseDataSourceItem) {
        SnackbarManager.shared.show(type: .nonCritical, message: localized(.changePersonThumbnailSuccess))
        if let router = router as? FaceImageChangeCoverRouterInput {
            router.back()
        }
    }
    
    func didSetCover(item: BaseDataSourceItem) {
        if let router = router as? FaceImageChangeCoverRouterInput {
            router.back()
        }
        
        if let item = item as? WrapData {
            customModuleOutput?.onAlbumCoverSelected(item: item)
        }
    }
    
}
