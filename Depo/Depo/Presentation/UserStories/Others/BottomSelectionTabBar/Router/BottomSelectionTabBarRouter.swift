//
//  BottomSelectionTabBarBottomSelectionTabBarRouter.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarRouter: BottomSelectionTabBarRouterInput {

    func onInfo(object: Item) {
        let router = RouterVC()
        let viewContr = router.fileInfo!
        guard let fileInfo = viewContr as? FileInfoViewController else {
            return
        }
        router.pushOnPresentedView(viewController: fileInfo)
        fileInfo.interactor.setObject(object: object)
    }
    
    func addToAlbum(items: [BaseDataSourceItem]) {
        let router = RouterVC()
        let controller = router.addPhotosToAlbum(photos: items)
        router.pushOnPresentedView(viewController: controller)
    }
    
    func showPrint(items: [BaseDataSourceItem]) {
        guard let wrapperedArray = items as? [Item] else {
            return
        }
        let router = RouterVC()
        let imagesOnly = wrapperedArray.filter { $0.fileType == .image }
        let vc = PrintInitializer.viewController(data: imagesOnly)
        router.pushOnPresentedView(viewController: vc)
    }
    
    func showSelectFolder(selectFolder: SelectFolderViewController) { }
    
    func showShare(rect: CGRect?, urls: [String]) { }
    
    func showDeleteMusic(_ completion: @escaping VoidHandler) { }
    
    func showErrorShareEmptyAlbums() {
        let router = RouterVC()
        let popUp = PopUpController.with(title: TextConstants.errorAlert,
                                         message: TextConstants.shareEmptyAlbumError,
                                         image: .error,
                                         buttonTitle: TextConstants.ok)
        router.presentViewController(controller: popUp)
    }
}
