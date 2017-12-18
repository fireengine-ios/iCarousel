//
//  AlbumDetailAlbumDetailRouter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailRouter: BaseFilesGreedRouter, AlbumDetailRouterInput {

    func back() {
        view.navigationController?.popViewController(animated: true)
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum) { return }
        if (item.fileType == .musicPlayList) { return }
        
        guard let wrappered = item as? Item else { return }
        guard let wrapperedArray = data as? [[Item]] else { return }
        
        switch item.fileType {
            case .folder:
                let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, moduleOutput: moduleOutput)
                router.pushViewControllertoTableViewNavBar(viewController: controller)
            case .audio:
                player.play(list: [wrappered], startAt: 0)
            default:
                let controller = router.filesDetailAlbumViewController(fileObject: wrappered, from: wrapperedArray)
                router.pushViewController(viewController: controller)
        }
    }
}
