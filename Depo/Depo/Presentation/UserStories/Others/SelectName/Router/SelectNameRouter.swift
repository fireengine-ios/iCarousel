//
//  SelectNameSelectNameRouter.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SelectNameRouter: SelectNameRouterInput {
    private let router = RouterVC()
    weak var presenter: SelectNamePresenter!

    func hideScreen() {
        let router = RouterVC()
        router.popViewController()
    }
    
    func moveToFolderPage(item: Item, isSubFolder: Bool) {
        if !isSubFolder {
            let allFilesVC = router.allFiles(moduleOutput: presenter, sortType: .None, viewType: .Grid)
            router.pushViewController(viewController: allFilesVC, animated: false)
        }
        
        let folderVC = router.filesFromFolder(folder: item, type: .Grid, sortType: .None, moduleOutput: presenter) 
        router.pushViewController(viewController: folderVC, animated: false)
    }
}
