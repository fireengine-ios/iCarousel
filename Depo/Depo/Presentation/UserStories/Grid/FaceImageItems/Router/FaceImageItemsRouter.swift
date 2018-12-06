//
//  FaceImageItemsRouter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsRouter: BaseFilesGreedRouter {
    let router = RouterVC()
}

// MARK: FaceImageItemsRouterInput

extension FaceImageItemsRouter: FaceImageItemsRouterInput {
    
    func openFaceImageItemPhotosWith(_ item: Item, album: AlbumItem, moduleOutput: FaceImageItemsModuleOutput?) {
        let vc = router.imageFacePhotosController(album: album, item: item, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func showPopUp() {
        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
        router.presentViewController(controller: popUp)
    }
    
    func openPremium(title: String, headerTitle: String, module: FaceImageItemsModuleOutput) {
        let vc = router.premium(title: title, headerTitle: headerTitle, module: module)
        router.pushViewController(viewController: vc)
    }
    
    func display(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
}
