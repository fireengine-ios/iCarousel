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
    
    class func initializeDocumentsViewController(with nibName: String) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.uploadDocuments, .createWord, .createExcel, .createPowerPoint])
        viewController.cardsContainerView.isEnable = true
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.upload, .download])
        viewController.segmentImage = .documents
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .moveToTrash],
                                               style: .default,
                                               tintColor: AppColor.tint.color,
                                               unselectedItemTintColor: AppColor.label.color,
                                               barTintColor: AppColor.drawerBackground.color)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: DocumentService(requestSize: 100),
                               fileFilters: [.fileType(.allDocs)],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select, .officeFilterAll, .officeFilterPdf, .officeFilterWord, .officeFilterCell, .officeFilterSlide],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        viewController.title = TextConstants.documents
        return viewController
    }
    
    class func initializeDocumentsAndMusicViewController(with nibName: String) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.uploadDocuments,.uploadMusic])
        viewController.cardsContainerView.isEnable = true
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.upload, .download])
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .moveToTrash],
                                               style: .default,
                                               tintColor: AppColor.tint.color,
                                               unselectedItemTintColor: AppColor.label.color,
                                               barTintColor: AppColor.drawerBackground.color)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController, remoteServices: DocumentsAndMusicService(requestSize: 100),
                               fileFilters: [.fileType(.documentsAndMusic)],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        viewController.title = TextConstants.documents
        return viewController
    }
    
    class func initializeAllFilesViewController(with nibName: String, moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let viewController = AllFilesViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.upload, .uploadFiles, .newFolder, .createWord, .createExcel, .createPowerPoint])
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.sync, .upload, .download])
        viewController.cardsContainerView.isEnable = true
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(
            elementsConfig:  [.share, .move, .moveToTrash],
            style: .default,
            tintColor: AppColor.tint.color,
            unselectedItemTintColor: AppColor.label.color,
            barTintColor: AppColor.drawerBackground.color
        )
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: viewType,
            availableSortTypes: allFilesSortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController,
                               moduleOutput: moduleOutput,
                               remoteServices: AllFilesService(requestSize: 100),
                               fileFilters: [.localStatus(.nonLocal), .parentless ],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.rename]),
                               alertSheetExcludeTypes: [.print])
        viewController.mainTitle = TextConstants.homeButtonAllFiles
        
        return viewController
    }
    
    class func initializeFavoritesViewController(with nibName: String, moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let viewController = BaseFilesGreedViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.uploadFromLifeboxFavorites])
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.upload, .download])
        viewController.cardsContainerView.isEnable = true
        viewController.isFavorites = true
        viewController.segmentImage = .favorites
        
        let configurator = BaseFilesGreedModuleConfigurator()
        
        var elementsConfig: [ElementTypes] = [.share, .move, .moveToTrash]
        
        if SingletonStorage.shared.accountInfo?.isUserFromTurkey == true {
            if let moveIndex = elementsConfig.firstIndex(of: .move) {
                elementsConfig.insert(.print, at: moveIndex + 1)
            }
        }
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .default,
                                               tintColor: AppColor.tint.color,
                                               unselectedItemTintColor: AppColor.label.color,
                                               barTintColor: AppColor.drawerBackground.color)
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: viewType,
            availableSortTypes: allFilesSortTypes,
            defaultSortType: sortType,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController,
                               moduleOutput: moduleOutput,
                               remoteServices: FavouritesService(requestSize: 100),
                               fileFilters: [.favoriteStatus(.favorites), .localStatus(.nonLocal)],
                                bottomBarConfig: bottomBarConfig,
                                topBarConfig: gridListTopBarConfig,
                                alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                      selectionModeTypes: [.rename]),
                                alertSheetExcludeTypes: [.print])
        viewController.mainTitle = TextConstants.homeButtonFavorites
        
        viewController.title = TextConstants.homeButtonFavorites
        return viewController
    }
    
    class func initializeFilesFromFolderViewController(with nibName: String, folder: Item, type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, status: ItemStatus, moduleOutput: BaseFilesGreedModuleOutput?, alertSheetExcludeTypes: [ElementTypes]? = nil) -> UIViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        if status == .active {
            viewController.floatingButtonsArray.append(contentsOf: [.upload, .uploadFiles, .newFolder, .createWord, .createExcel, .createPowerPoint])
        }
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.sync, .upload, .download])
        viewController.cardsContainerView.isEnable = true
        viewController.status = status
        viewController.plusButtonType = "Folder"
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let elementsConfig = ElementTypes.filesInFolderElementsConfig(for: status, viewType: .bottomBar)
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .default,
                                               tintColor: AppColor.tint.color,
                                               unselectedItemTintColor: AppColor.label.color,
                                               barTintColor: AppColor.drawerBackground.color)

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
