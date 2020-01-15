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
    class func initializeSelectFolderViewController(with nibName: String, folder: Item?, sortRule: SortedRules) -> SelectFolderViewController {
        let viewController = SelectFolderViewController(nibName: nibName, bundle: nil)
        let configurator = BaseFilesGreedModuleConfigurator()
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .moveToTrash],
                                               style: .default, tintColor: nil)
        
        let presentor = SelectFolderPresenter()
        presentor.sortedRule = sortRule
        
        var filters: [GeneralFilesFiltrationType] = [.fileType(.folder)]
        
        let interactor: BaseFilesGreedInteractor
        if let folder_ = folder {
            viewController.selectedFolder = folder
            interactor = BaseFilesGreedInteractor(remoteItems: FolderService(requestSize: 9999, rootFolder: folder_.uuid, onlyFolders: false))
            interactor.folder = folder_
            filters.append(.rootFolder(folder_.uuid))
        } else {
            interactor = BaseFilesGreedInteractor(remoteItems: FolderService(requestSize: 9999, onlyFolders: true))
        }
        
        configurator.configure(viewController: viewController,
                               fileFilters: filters, bottomBarConfig: bottomBarConfig,
                               router: BaseFilesGreedRouter(), presenter: presentor,
                               interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: nil)

        viewController.mainTitle = folder?.name ?? ""
        return viewController
    }

}
