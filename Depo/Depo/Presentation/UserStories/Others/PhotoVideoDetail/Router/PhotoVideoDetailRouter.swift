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
        let viewContr = router.fileInfo!
        guard let fileInfo = viewContr as? FileInfoViewController else {
            return
        }
        router.pushOnPresentedView(viewController: fileInfo)
        fileInfo.interactor.setObject(object: object) //FIXME: AGAIN!>!?!@>!@ interactor in vc!!@@!!@!@
    }
    
    func goBack(navigationConroller: UINavigationController?) {
        navigationConroller?.dismiss(animated: true, completion: nil)
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
