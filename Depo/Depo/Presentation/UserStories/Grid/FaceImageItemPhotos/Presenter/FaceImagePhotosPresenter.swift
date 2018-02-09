//
//  FaceImagePhotosPresenter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosPresenter: BaseFilesGreedPresenter {
    
    var coverPhotoURL = URL(string: "")
    let item: Item
    
    init(item: Item) {
        self.item = item
        super.init()
    }
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        loadItem()
    }
    
    override func changeCover() {
        if let itemsService = interactor.remoteItems as? FaceImageDetailService,
           let router = router as? FaceImagePhotosRouter {
              router.openChangeCoverWith(itemsService.albumUUID, moduleOutput: self)
        }
    }
    
    private func loadItem() {
        guard let view = view as? FaceImagePhotosViewController else {
            return
        }
        
        guard let item = item as? PeopleItem else {
            view.setHeaderViewHidden(true)
            return
        }
        
        view.loadAlbumsForPeopleItem(item)
        
        if let url = coverPhotoURL {
            view.setHeaderImage(with: url)
        }
        
        view.setHeaderViewHidden(false)
    }
}

extension FaceImagePhotosPresenter: FaceImageChangeCoverModuleOutput {
    func onAlbumCoverSelected(item: WrapData) {
        if let view = view as? FaceImagePhotosViewController, let coverURL = item.tmpDownloadUrl {
            view.setHeaderImage(with: coverURL)
        }
    }
}
