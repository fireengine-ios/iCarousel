//
//  StoriesInitializer.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikov on 15.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesInitializer: NSObject {
    
    static var storiesSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ,.AlphaBetricZA, .TimeNewOld, .TimeOldNew]
    }
    
    class func initializeStoriesController(with nibName:String) -> BaseFilesGreedChildrenViewController {
        let viewController = BaseFilesGreedChildrenViewController(nibName: nibName, bundle: nil)
        viewController.needShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.floatingButtonCreateAStory])
        let configurator = BaseFilesGreedModuleConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .download, .delete],
                                               style: .default, tintColor: nil)
        
        let presenter = AlbumsPresenter()
        
        let router = AlbumsRouter()
        router.presenter = presenter
        
        let interactor = StoriesInteractor(remoteItems: StoryService(requestSize: 140))
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: storiesSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        
        configurator.configure(viewController: viewController,
                               bottomBarConfig: bottomBarConfig, router: router,
                               presenter: presenter, interactor: interactor,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: [.completelyDeleteAlbums]),
                               topBarConfig: gridListTopBarConfig)
        
        interactor.originalFilters = [.fileType(.photoAlbum)]
        viewController.mainTitle = TextConstants.myStreamStoriesTitle
        
        return viewController
    }
}
