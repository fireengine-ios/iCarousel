//
//  SelectNameSelectNameRouter.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SelectNameRouter: SelectNameRouterInput {
    private let router = RouterVC()

    func hideScreen() {
        let router = RouterVC()
        router.popViewController()
    }
    
    func moveToFolderPage(presenter: SelectNamePresenter, item: Item, isSubFolder: Bool) {
        if !isSubFolder {
            let allFilesVC = router.allFiles(moduleOutput: presenter,
                                             sortType: presenter.allFilesSortType,
                                             viewType: presenter.allFilesViewType)
            router.pushViewController(viewController: allFilesVC)
        }
        
        let folderVC = router.filesFromFolder(folder: item, type: .Grid, sortType: .None, moduleOutput: presenter)
        router.pushViewController(viewController: folderVC)
    }
    
    func moveToAlbumPage(presenter: SelectNamePresenter, item: AlbumItem) {
        let albumVC = router.albumDetailController(album: item, type: .List, moduleOutput: presenter)
        router.pushViewController(viewController: albumVC)
    }
}
