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
    class func initializeAllFilesViewController(with nibName:String, output: SearchModuleOutput?) -> UIViewController {
        let viewController = SearchViewController(nibName: nibName, bundle: nil)
        let configurator = SearchViewConfigurator()
        
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .Grid,
            availableSortTypes: [],
            defaultSortType: .TimeNewOld,
            availableFilter: false,
            showGridListButton: true
        )
        
        configurator.configure(viewController: viewController, remoteServices: RemoteSearchService(requestSize: 100), output: output, topBarConfig: gridListTopBarConfig)
        
        return viewController
    }
}
