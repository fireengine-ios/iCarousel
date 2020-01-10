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
        let controller = router.hiddenAlbumDetailController(album: item, type: .List, moduleOutput: nil)
        router.pushViewController(viewController: controller)
    }
    
    func openFIRAlbum(album: AlbumItem, item: Item, moduleOutput: FaceImageItemsModuleOutput?) {
        let controller = router.imageFacePhotosController(album: album, item: item, status: .trashed, moduleOutput: moduleOutput)
        router.pushViewController(viewController: controller)
    }
    
    func openSelected(item: Item, sameTypeItems: [Item]) {
        switch item.fileType {
        case .folder:
            let controller = router.filesFromFolder(folder: item, type: .Grid, sortType: .TimeNewOld, status: .trashed, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
            
        case .audio:
            player.play(list: sameTypeItems, startAt: sameTypeItems.index(of: item) ?? 0)
            
        case .application(.usdz):
            let controller = router.augumentRealityDetailViewController(fileObject: item)
            router.presentViewController(controller: controller)
            
        default:
            let controller = router.filesDetailViewController(fileObject: item, items: sameTypeItems)
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
        }
    }
    
    func openSearch(controller: UIViewController?) {
        let controller = router.searchView(navigationController: controller?.navigationController, output: nil)
        router.pushViewController(viewController: controller)
    }
}
