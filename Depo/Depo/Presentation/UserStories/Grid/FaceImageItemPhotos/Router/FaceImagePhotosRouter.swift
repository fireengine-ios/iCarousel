//
//  FaceImagePhotosRouter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosRouter: BaseFilesGreedRouter {
    
    var item: Item?
    var faceImageType: FaceImageType?
    private lazy var router = RouterVC()
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        guard let wrappered = selectedItem as? Item else { return }
        guard let wrapperedArray = sameTypeItems as? [Item] else { return }
        
        let albumUUID = router.getParentUUID()
        let detailModule = router.filesDetailFaceImageAlbumModule(fileObject: wrappered,
                                                                  items: wrapperedArray,
                                                                  albumUUID: albumUUID,
                                                                  albumItem: item,
                                                                  status: view.status,
                                                                  moduleOutput: moduleOutput as? PhotoVideoDetailModuleOutput,
                                                                  faceImageType: faceImageType)
        
        presenter.photoVideoDetailModule = detailModule.moduleInput
        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController)
    }
    
    override func showBack() {
        router.popViewController()
    }
}

// MARK: FaceImagePhotosRouterInput

extension FaceImagePhotosRouter: FaceImagePhotosRouterInput {
    func openChangeThumbnailWith(_ albumUUID: String, personItem: Item, moduleOutput: FaceImageChangeCoverModuleOutput) {
        let vc = router.faceImageChangeCoverController(albumUUID: albumUUID, personItem: personItem, coverType: .thumbnail, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func openChangeCoverWith(_ albumUUID: String, moduleOutput: FaceImageChangeCoverModuleOutput) {
        let vc = router.faceImageChangeCoverController(albumUUID: albumUUID, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func openAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?, isSearchItem: Bool) {
        let vc = router.faceImageAddName(item, moduleOutput: moduleOutput, isSearchItem: isSearchItem)
        router.pushViewController(viewController: vc)
    }
}
