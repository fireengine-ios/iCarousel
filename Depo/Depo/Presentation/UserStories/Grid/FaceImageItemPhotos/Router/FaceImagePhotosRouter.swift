//
//  FaceImagePhotosRouter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosRouter: BaseFilesGreedRouter {
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        let router = RouterVC()
        
        guard let wrappered = selectedItem as? Item else { return }
        guard let wrapperedArray = sameTypeItems as? [Item] else { return }
        
        let albumUUID = RouterVC().getParentUUID()
        let controller = router.filesDetailAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID)
        let nController = UINavigationController(rootViewController: controller)
        RouterVC().presentViewController(controller: nController)
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
        let vc = RouterVC().faceImageAddName(item, moduleOutput: moduleOutput)
        
        RouterVC().pushViewController(viewController: vc)
    }
    
}
