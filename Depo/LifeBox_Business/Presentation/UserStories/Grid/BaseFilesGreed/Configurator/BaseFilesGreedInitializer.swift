//
//  BaseFilesGreedInitializer.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var baseFilesGreedViewController: BaseFilesGreedViewController!
    
    static var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    static var allFilesSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .lastModifiedTimeNewOld, .lastModifiedTimeOldNew, .Largest, .Smallest]
    }
    
    class func initializeFilesFromFolderViewController(with nibName: String, folder: Item, type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, status: ItemStatus, moduleOutput: BaseFilesGreedModuleOutput?, alertSheetExcludeTypes: [ElementTypes]? = nil) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        if status == .active {
            viewController.floatingButtonsArray.append(contentsOf: [.upload(type: .regular), .uploadFiles(type: .regular), .newFolder(type: .regular)])
        }
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.upload, .download])
        viewController.cardsContainerView.isEnable = true
        viewController.status = status
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let elementsConfig = ElementTypes.filesInFolderElementsConfig(for: status, viewType: .bottomBar)
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .default, tintColor: nil)

        let sortedRule: SortedRules = status == .active ? .lastModifiedTimeDown : .timeDown
        let presenter = DocumentsGreedPresenter(sortedRule: sortedRule)
        presenter.sortedType = sortType
        
        if let alertSheetExcludeTypes = alertSheetExcludeTypes {
            presenter.alertSheetExcludeTypes = alertSheetExcludeTypes
        }

        let filesService = FilesFromFolderService(requestSize: 999, rootFolder: folder.uuid, status: status)
        let interactor = BaseFilesGreedInteractor(remoteItems: filesService)
        interactor.folder = folder
        interactor.parent = folder
        viewController.parentUUID = folder.uuid
        
        if let output = moduleOutput {
            presenter.moduleOutput = output
        }
        
        let sortTypes = status == .active ? allFilesSortTypes : baseSortTypes
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: type,
            availableSortTypes: sortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        
        let alertFilesActionsTypes = ElementTypes.filesInFolderElementsConfig(for: status, viewType: .actionSheet)
        let selectionModeTypes = ElementTypes.filesInFolderElementsConfig(for: status, viewType: .selectionMode)
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: alertFilesActionsTypes,
                                                                   selectionModeTypes: selectionModeTypes)
        
        configurator.configure(viewController: viewController, fileFilters: [.rootFolder(folder.uuid), .localStatus(.nonLocal), .fileType(.folder)],
                               bottomBarConfig: bottomBarConfig, router: BaseFilesGreedRouter(),
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: alertSheetConfig,
                               topBarConfig: gridListTopBarConfig)
        
        viewController.mainTitle = folder.name ?? ""

        return viewController
    }

}
