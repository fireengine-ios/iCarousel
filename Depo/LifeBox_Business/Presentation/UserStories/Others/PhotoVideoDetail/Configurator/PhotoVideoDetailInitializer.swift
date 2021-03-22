//
//  PhotoVideoDetailPhotoVideoDetailInitializer.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

typealias PhotoVideoDetailModule = (controller: PhotoVideoDetailViewController, moduleInput: PhotoVideoDetailModuleInput)

class PhotoVideoDetailModuleInitializer: NSObject {

    class func initializeViewController(with nibName: String, moduleOutput: PhotoVideoDetailModuleOutput? = nil, selectedItem: Item, allItems: [Item], status: ItemStatus, canLoadMoreItems: Bool) -> PhotoVideoDetailModule {
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status)
        
        let bottomBarConfig = EditingBarConfig(elementsConfig: elementsConfig,
                                               style: .transparent)
        
        let viewController = PhotoVideoDetailViewController(nibName: nibName, bundle: nil)
//        initinalBarStyle
        if case .application = selectedItem.fileType {
            viewController.initinalBarStyle = .white
        } else {
            viewController.initinalBarStyle = .transparent
        }
        
        let configurator = PhotoVideoDetailModuleConfigurator()
        let presenter = PhotoVideoDetailPresenter()
        configurator.configureModuleForViewInput(viewInput: viewController,
                                                 presenter: presenter,
                                                 moduleOutput: moduleOutput,
                                                 bottomBarConfig: bottomBarConfig,
                                                 selecetedItem: selectedItem,
                                                 allItems: allItems,
                                                 status: status,
                                                 canLoadMoreItems: canLoadMoreItems)
        return (viewController, presenter)
    }
}
