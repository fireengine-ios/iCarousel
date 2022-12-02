//
//  AnimationsInitializer.swift
//  Depo
//
//  Created by Ozan Salman on 29.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class AnimationsInitializer: NSObject {
    
    static var animationsSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.LettersAZ, .LettersZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }
    
    class func initializeAnimationController(with nibName: String, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.floatingButtonsArray.append(contentsOf: [.upload])
        viewController.isControllerCollageAnimations = true
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
        
        let interactor = AnimationInteractor(remoteItems: AnimationService(requestSize: 140))
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: animationsSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: router,
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.addToAlbum]),
                               topBarConfig: gridListTopBarConfig)
        
        interactor.originalFilters = [.fileType(.photoAlbum)]
        viewController.mainTitle = localized(.forYouAnimationsTitle)
        
        return viewController
    }
}

