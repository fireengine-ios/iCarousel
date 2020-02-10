//
//  AlbumDetailAlbumDetailRouter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class AlbumDetailRouter: BaseFilesGreedRouter {
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        guard
            let wrappered = selectedItem as? Item,
            let wrapperedArray = sameTypeItems as? [Item],
            !selectedItem.fileType.isContained(in: [.photoAlbum, .musicPlayList])
            else {
                return
        }
        
        let router = RouterVC()
        switch selectedItem.fileType {
        case .folder:
            let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, status: view.status, moduleOutput: moduleOutput)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            player.play(list: [wrappered], startAt: 0)
        default:
            let albumUUID = router.getParentUUID()
            let controller = router.filesDetailAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID, status: view.status)
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
        }
    }
}
