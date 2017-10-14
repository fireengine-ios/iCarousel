//
//  SelectFolderMoveInitializer.swift
//  Depo
//
//  Created by Oleg on 07/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectFolderModuleInitializer: NSObject {

    //Connect with object on storyboard
    class func initializeSelectFolderViewController(with nibName:String, folder: Item?) -> SelectFolderViewController {
        let viewController = SelectFolderViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share,.move,.delete],
                                               style: .default, tintColor: nil)
        
        let presentor = SelectFolderPresenter()
        
        
        let interactor: BaseFilesGreedInteractor
        if let folder_ = folder{
            viewController.selectedFolder = folder
            interactor = BaseFilesGreedInteractor(remoteItems: FolderService(requestSize: 999, rootFolder: folder_.uuid))
            interactor.folder = folder_
        }else{
            interactor = BaseFilesGreedInteractor(remoteItems: FolderService(requestSize: 9999))
        }
        
        configurator.configure(viewController: viewController, bottomBarConfig: bottomBarConfig,
                               router: BaseFilesGreedRouter(), presenter: presentor,
                               interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select, .selectAll],
                                                                                     selectionModeTypes: []))
        if let folder_ = folder{
            viewController.mainTitle = folder_.name
        }else{
            viewController.mainTitle = ""
        }
        return viewController
    }

}
