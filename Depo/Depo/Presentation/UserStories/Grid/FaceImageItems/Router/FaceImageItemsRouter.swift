//
//  FaceImageItemsRouter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsRouter: BaseFilesGreedRouter, FaceImageItemsRouterInput {
    func openFaceImageItemPhotosWith(_ item: Item, albumUUID: String, moduleOutput: FaceImageItemsModuleOutput?) {
        let router = RouterVC()

        router.pushViewController(viewController: router.imageFacePhotosController(albumUUID: albumUUID, item: item, moduleOutput: moduleOutput))
    }
}
