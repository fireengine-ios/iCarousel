//
//  UploadFromLifeBoxUploadFromLifeBoxRouter.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxRouter: BaseFilesGreedRouter {
    
}

// MARK: UploadFromLifeBoxRouterInput
extension UploadFromLifeBoxRouter: UploadFromLifeBoxRouterInput {
    
    func goToFolder(destinationFolderUUID: String, outputFolderUUID: String, nController: UINavigationController) {
        let viewController = RouterVC().uploadFromLifeBox(folderUUID: destinationFolderUUID, soorceUUID: outputFolderUUID, sortRule: presenter.sortedRule)
        nController.pushViewController(viewController, animated: true)
    }
}

class UploadFromLifeBoxRouterFavorites: BaseFilesGreedRouter {
    
}

// MARK: UploadFromLifeBoxRouterInput
extension UploadFromLifeBoxRouterFavorites: UploadFromLifeBoxRouterInput {
    
    func goToFolder(destinationFolderUUID: String, outputFolderUUID: String, nController: UINavigationController) {
        let viewController = RouterVC().uploadFromLifeBoxFavorites(folderUUID: destinationFolderUUID, soorceUUID: outputFolderUUID, sortRule: presenter.sortedRule, isPhotoVideoOnly: false)
        nController.pushViewController(viewController, animated: true)
    }
}
