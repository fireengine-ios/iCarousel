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
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        if let view = view as? FaceImagePhotosViewController, let url = coverPhotoURL {
            view.setHeaderImage(with: url)
        }
    }
    
    override func changeCover() {
        if let itemsService = interactor.remoteItems as? FaceImageDetailService,
           let router = router as? FaceImagePhotosRouter {
              router.openChangeCoverWith(itemsService.albumUUID, moduleOutput: self)
        }
    }
}

extension FaceImagePhotosPresenter: FaceImageChangeCoverModuleOutput {
    func onAlbumCoverSelected(item: WrapData) {
        if let view = view as? FaceImagePhotosViewController, let coverURL = item.tmpDownloadUrl {
            view.setHeaderImage(with: coverURL)
        }
    }
}
