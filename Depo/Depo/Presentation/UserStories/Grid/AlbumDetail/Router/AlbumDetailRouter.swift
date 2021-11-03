//
//  AlbumDetailAlbumDetailRouter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class AlbumDetailRouter: BaseFilesGreedRouter {

    private lazy var router = RouterVC()

    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        
        guard
            let wrappered = selectedItem as? Item,
            let wrapperedArray = sameTypeItems as? [Item],
            !selectedItem.fileType.isContained(in: [.photoAlbum, .musicPlayList])
            else {
                return
        }
        
        switch selectedItem.fileType {
        case .folder:
            let controller = router.filesFromFolder(folder: wrappered, type: type, sortType: sortType, status: view.status, moduleOutput: moduleOutput)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            player.play(list: [wrappered], startAt: 0)
        default:
            let albumUUID = router.getParentUUID()
            let detailModule = router.filesDetailAlbumModule(fileObject: wrappered,
                                                             items: wrapperedArray,
                                                             albumUUID: albumUUID,
                                                             status: view.status,
                                                             moduleOutput: moduleOutput as? PhotoVideoDetailModuleOutput)
            
            presenter.photoVideoDetailModule = detailModule.moduleInput
            let nController = NavigationController(rootViewController: detailModule.controller)
            router.presentViewController(controller: nController)
        }
    }
}

extension AlbumDetailRouter {
    func openChangeCoverWith(_ albumUUID: String, moduleOutput: FaceImageChangeCoverModuleOutput) {
        let vc = router.faceImageChangeCoverController(albumUUID: albumUUID, moduleOutput: moduleOutput)
        router.pushViewController(viewController: vc)
    }
}
