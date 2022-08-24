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
        case .faceImage:
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
        case .photopick:
            break
        }
    }
    
    func navigateToFaceImage() {
        let vc = router.faceImage
        router.pushViewController(viewController: vc)
    }
    
    func navigateToCreate(for view: ForYouViewEnum) {
        switch view {
        case .albums:
            let createAlbum = router.createNewAlbum()
            router.pushViewController(viewController: createAlbum)
        case .photopick:
            // TODO: Facelift: navigate to new photopick
            return
        default:
            return
        }
    }
}

