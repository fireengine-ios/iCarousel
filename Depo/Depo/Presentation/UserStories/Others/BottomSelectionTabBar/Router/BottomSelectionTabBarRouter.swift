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
        guard let fileInfo = viewContr as? FileInfoViewController else{
            return
        }
        router.pushViewController(viewController: fileInfo)
        fileInfo.interactor.setObject(object: object)
    }
    
    func addToAlbum(items: [BaseDataSourceItem]){
        let router = RouterVC()
        let controller = router.addPhotosToAlbum(photos: items)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    func showPrint(items: [BaseDataSourceItem]) {
        guard let wrapperedArray = items as? [Item] else {
            return
        }
        let router = RouterVC()
        
        let vc = PrintInitializer.viewController(data: wrapperedArray)
        router.pushViewController(viewController: vc)
    }
    
    func showSelectFolder(selectFolder: SelectFolderViewController) { }
    
    func showShare(rect: CGRect?, urls: [String]) { }
}
