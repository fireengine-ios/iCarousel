//
//  FaceImageItemsRouter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsRouter: BaseFilesGreedRouter, FaceImageItemsRouterInput {
    func openFaceImageItemPhotosWith(_ item: Item, albumUUID: String, coverPhotoURL: URL) {
        let router = RouterVC()
        let vc = router.imageFacePhotosController(albumUUID: albumUUID, item: item, coverPhotoURL: coverPhotoURL)
        router.pushViewController(viewController: vc)
    }
}
