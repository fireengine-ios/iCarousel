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
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        let router = RouterVC()
        
        guard let wrappered = selectedItem as? Item else { return }
        guard let wrapperedArray = sameTypeItems as? [Item] else { return }
        
        let albumUUID = router.getParentUUID()
        let controller = router.filesDetailFaceImageAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID, albumItem: item)
        let nController = NavigationController(rootViewController: controller)
        RouterVC().presentViewController(controller: nController)
    }
    
    override func showBack() {
        RouterVC().popViewController()
    }
}

// MARK: FaceImagePhotosRouterInput

extension FaceImagePhotosRouter: FaceImagePhotosRouterInput {
    
    func openChangeCoverWith(_ albumUUID: String, moduleOutput: FaceImageChangeCoverModuleOutput) {
        let router = RouterVC()
        let vc = router.faceImageChangeCoverController(albumUUID: albumUUID, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func openAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?) {
        let router = RouterVC()
        
        let vc = router.faceImageAddName(item, moduleOutput: moduleOutput)
        
        RouterVC().pushViewController(viewController: vc)
    }
    
    func showRemoveFromAlbum(completion: @escaping (() -> Void)) {
        let controller = PopUpController.with(title: TextConstants.actionSheetRemove,
                                              message: TextConstants.removeFromAlbum,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: completion)
        })
        
        RouterVC().presentViewController(controller: controller)
    }
    
}
