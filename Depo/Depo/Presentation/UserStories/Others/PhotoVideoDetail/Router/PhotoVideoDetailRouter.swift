//
//  PhotoVideoDetailPhotoVideoDetailRouter.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailRouter: PhotoVideoDetailRouterInput {
    weak var output: PhotoVideoDetailRouterOutput?
    
    let router = RouterVC()

    func onInfo(object: Item) {
        let router = RouterVC()
        let fileInfo = router.fileInfo(item: object)
        router.pushOnPresentedView(viewController: fileInfo)
    }
    
    func goBack(navigationConroller: UINavigationController?) {
        navigationConroller?.dismiss(animated: true, completion: nil)
    }
    
    func showConfirmationPopup(completion: @escaping () -> ()) {
        let okHandler: PopUpButtonHandler = { vc in
            vc.close()
            completion()
        }
        
        let cancelHandler: PopUpButtonHandler = { vc in
            vc.close()
        }
        
        let vc = PopUpController.with(title: TextConstants.faceImageEnable,
                                      message: TextConstants.faceImageEnableMessageText,
                                      image: .none,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      firstAction: cancelHandler,
                                      secondAction: okHandler)
        DispatchQueue.toMain {
            UIApplication.topController()?.present(vc, animated: false, completion: nil)
        }
    }
    
    func goToPremium() {
        router.pushViewController(viewController: router.premium())
    }
    
    func openFaceImageItemPhotosWith(_ item: Item, album: AlbumItem, moduleOutput: FaceImageItemsModuleOutput?) {
        let vc = router.imageFacePhotosController(album: album, item: item, status: .active, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
    
    func openPrivateShare(for item: Item) {
        let controller = router.privateShare(items: [item]) { [weak self] success in
            if success {
                self?.output?.updateShareInfo()
            }
        }
        router.presentViewController(controller: controller)
    }
    
    func openPrivateShareContacts(with shareInfo: SharedFileInfo) {
        let controller = router.privateShareContacts(with: shareInfo) { [weak self] in
            self?.output?.deleteShareInfo()
        }
        router.pushViewController(viewController: controller)
    }
}
