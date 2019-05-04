//
//  SearchViewInitializer.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchModuleOutput: class {
    func cancelSearch()
    func previewSearchResultsHide()
}

class SearchViewInitializer {
    class func initializeSearchViewController(with nibName: String, output: SearchModuleOutput?) -> SearchViewController {
        let viewController = SearchViewController(nibName: nibName, bundle: nil)
        let configurator = SearchViewConfigurator()
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: [],
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: [.share, .move, .delete],
                                               style: .default, tintColor: nil)
        
        configurator.configure(viewController: viewController,
                               remoteServices: RemoteSearchService(requestSize: 100),
                               recentSearches: RecentSearchesService.shared,
                               output: output,
                               topBarConfig: gridListTopBarConfig,
                               bottomBarConfig: bottomBarConfig,
                               alertSheetConfig: AlertFilesActionsSheetInitialConfig(initialTypes: [.select], selectionModeTypes: [.rename]),
                               alertSheetExcludeTypes: [.print])
        
        return viewController
    }
}
