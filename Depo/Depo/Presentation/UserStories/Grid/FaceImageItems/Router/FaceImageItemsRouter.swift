//
//  FaceImageItemsRouter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsRouter: BaseFilesGreedRouter {
    
}

// MARK: FaceImageItemsRouterInput

extension FaceImageItemsRouter: FaceImageItemsRouterInput {
    
    func openFaceImageItemPhotosWith(_ item: Item, albumUUID: String, coverPhotoURL: URL, moduleOutput: FaceImageItemsModuleOutput?) {
        let router = RouterVC()
        let vc = router.imageFacePhotosController(albumUUID: albumUUID, item: item, coverPhotoURL: coverPhotoURL, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
}

