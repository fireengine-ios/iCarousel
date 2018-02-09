//
//  FaceImagePhotosPresenter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosPresenter: BaseFilesGreedPresenter, FaceImagePhotosViewOutput, FaceImagePhotosModuleOutput {

    weak var faceImageItemsModuleOutput: FaceImageItemsModuleOutput?
    
    var currentItem: WrapData?

    override func changeCover() {
        if let itemsService = interactor.remoteItems as? FaceImageDetailService,
           let router = router as? FaceImagePhotosRouter {
              router.openChangeCoverWith(itemsService.albumUUID)
        }
    }
    
    // MARK: FaceImagePhotosViewOutput
    
    func openAddName() {
        if let router = router as? FaceImagePhotosRouter,
            let item = currentItem{
            router.openAddName(item, moduleOutput: self)
        }
    }
    
    // MARK: FaceImagePhotosModuleOutput
    
    func didChangeName(item: WrapData) {
        if let view = view as? FaceImagePhotosViewInput,
            let name = item.name {
                view.reloadName(name)
                faceImageItemsModuleOutput?.didChangeName(item: item)
        }
    }
    
    func didMergePeople() {
        faceImageItemsModuleOutput?.didMergePeople()
        reloadData()
    }
    
}
