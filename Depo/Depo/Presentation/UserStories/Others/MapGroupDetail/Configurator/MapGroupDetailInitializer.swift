//
//  MapGroupDetailInitializer.swift
//  Depo
//
//  Created by Hady on 3/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import CoreLocation

final class MapGroupDetailInitializer {
    static let bottomElements: [ElementTypes] = [.share, .download, .addToAlbum, .hide, .delete]

    class func initialize(nibName: String, coordinate: CLLocationCoordinate2D) -> MapGroupDetailViewController {
        let viewController = MapGroupDetailViewController(nibName: nibName, bundle: nil)

        viewController.status = .active
        viewController.needToShowTabBar = false
        viewController.floatingButtonsArray = []
        viewController.cardsContainerView.isEnable = false
        viewController.mainTitle = localized(.mapLocationDetailHeader)

        let presenter = BaseFilesGreedPresenter()
        let interactor = BaseFilesGreedInteractor(remoteItems: MapGroupDetailService(coordinate: coordinate))


        let bottomBarConfig = EditingBarConfig(elementsConfig: Self.bottomElements, style: .default, tintColor: nil)
        let alertSheetConfig = AlertFilesActionsSheetInitialConfig(initialTypes: [], selectionModeTypes: [])
        let gridListTopBarConfig = GridListTopBarConfig(
            defaultGridListViewtype: .List,
            availableSortTypes: [],
            defaultSortType: .None,
            availableFilter: false,
            showGridListButton: false
        )

        let configurator = BaseFilesGreedModuleConfigurator()
        configurator.configure(viewController: viewController,
                               fileFilters: [],
                               bottomBarConfig: bottomBarConfig,
                               router: BaseFilesGreedRouter(),
                               presenter: presenter,
                               interactor: interactor,
                               alertSheetConfig: alertSheetConfig,
                               topBarConfig: gridListTopBarConfig)
        return viewController
    }
}
