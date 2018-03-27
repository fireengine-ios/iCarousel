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
    
    func openFaceImageItemPhotosWith(_ item: Item, album: AlbumItem, moduleOutput: FaceImageItemsModuleOutput?) {
        let router = RouterVC()
        let vc = router.imageFacePhotosController(album: album, item: item, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func showPopUp() {
        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
        
        RouterVC().presentViewController(controller: popUp)
    }
    
}
