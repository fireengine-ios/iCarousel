//
//  FavoriteInitializer.swift
//  Depo
//
//  Created by Ozan Salman on 11.01.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

class FavoriteInitializer: NSObject {
    
    static var favoriteSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.LettersAZ, .LettersZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    class func initializeFavoriteController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needToShowTabBar = false
        viewController.floatingButtonsArray.append(contentsOf: [.uploadFiles, .uploadFromLifeboxFavorites])
        viewController.cardsContainerView.addPermittedPopUpViewTypes(types: [.upload, .download])
        viewController.cardsContainerView.isEnable = true
        viewController.forYouControllerSection = .favorites
        viewController.isFavorites = true
        
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .moveToTrash],
                                               style: .default, tintColor: AppColor.tint.color,
                                               unselectedItemTintColor: AppColor.label.color,
                                               barTintColor: AppColor.drawerBackground.color)
        
        let presenter = AlbumsPresenter()
        
        if let moduleOutput = moduleOutput {
            presenter.sliderModuleOutput = moduleOutput
        }
        
        let router = AlbumsRouter()
        router.presenter = presenter
        
        let interactor = FavoriteInteractor(remoteItems: FavoriteService(requestSize: 140))
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: favoriteSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: router,
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []),
                               topBarConfig: gridListTopBarConfig)
        
        //interactor.originalFilters = [.fileType(.photoAlbum)]
        viewController.mainTitle = TextConstants.containerFavourite
        
        return viewController
    }
}

