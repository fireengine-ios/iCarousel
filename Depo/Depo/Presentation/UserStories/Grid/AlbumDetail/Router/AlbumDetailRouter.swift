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
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {

        let router = RouterVC()
        
        if (selectedItem.fileType == .photoAlbum) { return }
        if (selectedItem.fileType == .musicPlayList) { return }
        
        guard let wrappered = selectedItem as? Item else { return }
        guard let wrapperedArray = sameTypeItems as? [Item] else { return }
        
        switch selectedItem.fileType {
            case .folder:
                let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, status: .active, moduleOutput: moduleOutput)
                router.pushViewControllertoTableViewNavBar(viewController: controller)
            case .audio:
                player.play(list: [wrappered], startAt: 0)
            default:
                let albumUUID = RouterVC().getParentUUID()
                let controller = router.filesDetailAlbumViewController(fileObject: wrappered, items: wrapperedArray, albumUUID: albumUUID)
                let nController = NavigationController(rootViewController: controller)
                RouterVC().presentViewController(controller: nController)
        }
    }
}
