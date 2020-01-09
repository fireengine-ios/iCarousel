//
//  MusicInitializer.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 8/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class MusicInitializer {
    
    static var baseSortTypes: [MoreActionsConfig.SortRullesType] {
        return [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    }

    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = MusicViewController(nibName: nibName, bundle: nil)
        
        viewController.needToShowTabBar = true
        viewController.floatingButtonsArray.append(contentsOf: [.importFromSpotify])
        viewController.scrollablePopUpView.isEnable = false
        viewController.segmentImage = .music
        
        let configurator = MusicConfigurator()
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .delete],
                                               style: .default, tintColor: nil)

        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: baseSortTypes,
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        configurator.configure(viewController: viewController,
                               remoteServices: MusicService(requestSize: 100),
                               fileFilters: [.fileType(.audio)],
                               bottomBarConfig: bottomBarConfig,
                               topBarConfig: gridListTopBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select],
                                                                                     selectionModeTypes: []))
        viewController.mainTitle = ""
        viewController.title = TextConstants.music
        return viewController
    }
}
