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
        let folderVC = router.filesFromFolder(folder: item, type: .Grid, sortType: .None, status: .active, moduleOutput: presenter)

        if
            let tabBarVC = router.defaultTopController?.presentingViewController as? TabBarViewController,
            let navVC = tabBarVC.activeNavigationController,
            let homePage = navVC.topViewController as? HomePageViewController
        {
            homePage.isNeedShowSpotlight = false
        } else {
            assertionFailure("Сondition not match expectations, homePage's spotlight must be delayed")
        }
        
        if !isSubFolder {
            let allFilesVC = router.allFiles(moduleOutput: presenter,
                                             sortType: presenter.allFilesSortType,
                                             viewType: presenter.allFilesViewType)
            router.pushSeveralControllers([allFilesVC, folderVC])
            
        } else {
            router.pushViewController(viewController: folderVC)
            
        }
    }
    
    func moveToAlbumPage(presenter: SelectNamePresenter, item: AlbumItem) {
        let albumVC = router.albumDetailController(album: item, type: .List, status: .active, moduleOutput: presenter)
        router.pushViewController(viewController: albumVC)
    }
}
