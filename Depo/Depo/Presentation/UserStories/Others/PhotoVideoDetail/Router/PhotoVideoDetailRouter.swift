//
//  PhotoVideoDetailPhotoVideoDetailRouter.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailRouter: PhotoVideoDetailRouterInput {

    func onInfo(object: Item) {
        let router = RouterVC()
        let fileInfo = router.fileInfo(item: object)
        router.pushOnPresentedView(viewController: fileInfo)
    }
    
    func goBack(navigationConroller: UINavigationController?) {
        navigationConroller?.dismiss(animated: true, completion: nil)
    }
    
}
