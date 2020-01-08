//
//  HiddenAlbumDetailRouter.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class HiddenAlbumDetailRouter: AlbumDetailRouter {

    override func onItemSelected(
        selectedItem: BaseDataSourceItem,
        sameTypeItems: [BaseDataSourceItem],
        type: MoreActionsConfig.ViewType,
        sortType: MoreActionsConfig.SortRullesType,
        moduleOutput: BaseFilesGreedModuleOutput?
    ) {

        let router = RouterVC()
        
        if (selectedItem.fileType == .photoAlbum) { return }
        if (selectedItem.fileType == .musicPlayList) { return }
        
        guard let wrappered = selectedItem as? Item else { return }
        guard let wrapperedArray = sameTypeItems as? [Item] else { return }
        
        switch selectedItem.fileType {
            case .folder:
                let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, moduleOutput: moduleOutput)
                router.pushViewControllertoTableViewNavBar(viewController: controller)
            case .audio:
                player.play(list: [wrappered], startAt: 0)
            default:
                let albumUUID = RouterVC().getParentUUID()
                let controller = router.filesDetailHiddenAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID, albumItem: wrappered)
                guard let viewController = controller else {
                    assertionFailure()
                    return
                }
                
                let nController = NavigationController(rootViewController: viewController)
                RouterVC().presentViewController(controller: nController)
        }
    }
}
