//
//  BottomSelectionTabBarBottomSelectionTabBarRouter.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarRouter: BottomSelectionTabBarRouterInput {
    
    private lazy var router = RouterVC()

    func onInfo(object: Item) {
        let fileInfo = router.fileInfo(item: object)
        router.pushOnPresentedView(viewController: fileInfo)
    }
    
    func showPrint(items: [BaseDataSourceItem]) {
        guard let wrapperedArray = items as? [Item] else {
            return
        }

        let imagesOnly = wrapperedArray.filter { $0.fileType == .image }
        let vc = PrintInitializer.viewController(data: imagesOnly)
        router.pushOnPresentedView(viewController: vc)
    }
    
    func showSelectFolder(selectFolder: SelectFolderViewController) { }
    
    func showShare(rect: CGRect?, urls: [String]) { }
    
    func showDeleteMusic(_ completion: @escaping VoidHandler) { }
    
    func showErrorShareEmptyAlbums() {
        let popUp = PopUpController.with(title: TextConstants.errorAlert,
                                         message: TextConstants.shareEmptyAlbumError,
                                         image: .error,
                                         buttonTitle: TextConstants.ok)
        router.presentViewController(controller: popUp)
    }
}
