//
//  TrashBinRouter.swift
//  Depo
//
//  Created by Andrei Novikau on 1/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class TrashBinRouter {
    
    private lazy var router = RouterVC()
    private lazy var player: MediaPlayer = factory.resolve()
    
    func openAlbum(item: AlbumItem) {
        let controller = router.albumDetailController(album: item, type: .List, status: .trashed, moduleOutput: nil)
        router.pushViewController(viewController: controller)
    }
    
    func openFIRAlbum(album: AlbumItem, item: Item) {
        let controller = router.imageFacePhotosController(album: album, item: item, status: .trashed, moduleOutput: nil)
        router.pushViewController(viewController: controller)
    }
    
    func openSelected(item: Item, sameTypeItems: [Item], delegate: TrashBinViewController) {
        switch item.fileType {
        case .folder:
            let controller = router.filesFromFolder(folder: item, type: .Grid, sortType: .TimeNewOld, status: .trashed, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
            
        case .audio:
            player.play(list: sameTypeItems, startAt: sameTypeItems.firstIndex(of: item) ?? 0)
            
        case .application(.usdz):
            let controller = router.augumentRealityDetailViewController(fileObject: item)
            router.presentViewController(controller: controller)
            
        default:
            let detailModule = router.filesDetailModule(fileObject: item,
                                                        items: sameTypeItems,
                                                        status: .trashed,
                                                        canLoadMoreItems: false,
                                                        moduleOutput: delegate)
            
            delegate.photoVideoDetailModule = detailModule.moduleInput
            let nController = NavigationController(rootViewController: detailModule.controller)
            router.presentViewController(controller: nController)
        }
    }
    
    func openSearch(controller: UIViewController?) {
        let controller = router.searchView(navigationController: controller?.navigationController, output: nil)
        router.pushViewController(viewController: controller)
    }
    
    func openInfo(item: Item) {
        let controller = router.fileInfo(item: item)
        router.pushViewController(viewController: controller)
    }
}
