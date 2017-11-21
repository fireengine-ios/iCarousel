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
        configurator.configure(viewController: viewController, remoteServices: RemoteSearchService(requestSize: 100), output: output)
        return viewController
    }
}
