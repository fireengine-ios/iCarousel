//
//  FaceImagePhotosRouter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosRouter: BaseFilesGreedRouter, FaceImagePhotosRouterInput {
    func openChangeCoverWith(_ albumUUID: String) {
        let router = RouterVC()
        let vc = router.faceImageChangeCoverController(albumUUID: albumUUID)
        router.pushViewController(viewController: vc)
    }
}
