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
        if let tabBarVC = router.defaultTopController as? TabBarViewController,
           let navVC = tabBarVC.activeNavigationController,
           let controller = navVC.topViewController as? PrivateShareSharedFilesViewController {
            if let projectId = item.projectId, let name = item.name, let permission = item.privateSharePermission {
                let newFolder = PrivateSharedFolderItem(projectId: projectId, uuid: item.uuid, name: name, permissions: permission)
                let newController = router.sharedFolder(rootShareType: controller.shareType, folder: newFolder)
                router.pushViewController(viewController: newController)
            }
            
            return
        }
        
        let folderVC = router.filesFromFolder(folder: item, type: .Grid, sortType: .None, status: .active, moduleOutput: presenter)

        if !isSubFolder {
            let allFilesVC = router.allFiles(moduleOutput: presenter,
                                             sortType: presenter.allFilesSortType,
                                             viewType: presenter.allFilesViewType)
            router.pushSeveralControllers([allFilesVC, folderVC])
            
        } else {
            router.pushViewController(viewController: folderVC)
            
        }
    }
}
