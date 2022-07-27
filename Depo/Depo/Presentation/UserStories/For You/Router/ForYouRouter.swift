//
//  ForYouRouter.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouRouter: ForYouRouterInput {
    private let router = RouterVC()
    weak var presenter: ForYouPresenter!
    
    func navigateToSeeAll(for view: ForYouViewEnum) {
        switch view {
        case .faceImage, .throwback, .collage:
            break
        case .people:
            let people = router.peopleListController()
            router.pushViewController(viewController: people)
        case .things:
            let things = router.thingsListController()
            router.pushViewController(viewController: things)
        case .places:
            let places = router.placesListController()
            router.pushViewController(viewController: places)
        case .albums:
            let albums = router.albumsListController()
            router.pushViewController(viewController: albums)
        }
    }
}

