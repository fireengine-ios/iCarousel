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
        
        let isComparableFileType = !selectedItem.fileType.isContained(in: [.musicPlayList, .photoAlbum])
        guard
            isComparableFileType,
            let wrappered = selectedItem as? Item,
            let wrapperedArray = sameTypeItems as? [Item]
        else {
            return
        }
        
        let router = RouterVC()
        
        switch selectedItem.fileType {
            case .folder:
                let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, status: .hidden, moduleOutput: moduleOutput)
                router.pushViewControllertoTableViewNavBar(viewController: controller)
            case .audio:
                player.play(list: [wrappered], startAt: 0)
            default:
                let albumUUID = router.getParentUUID()
                let controller = router.filesDetailHiddenAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID, albumItem: wrappered)
                guard let viewController = controller else {
                    assertionFailure()
                    return
                }
                
                let nController = NavigationController(rootViewController: viewController)
                router.presentViewController(controller: nController)
        }
    }
}
