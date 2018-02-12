//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderRouter: LBAlbumLikePreviewSliderRouterInput {
    
    let router = RouterVC()
    
    func onItemSelected(_ item: SliderItem) {
        guard let type = item.type else {
            return
        }
        
        switch type {
        case .albums: goToAlbumListView()
        case .story: goToStoryListView()
        case .people: goToPeopleListView()
        case .things: goToThingListView()
        case .places: goToPlaceListView()
        case .album:
            guard let albumItem = item.albumItem else {
                break
            }
            goToAlbumDetailView(album: albumItem)
        }
    }
    
    func goToAlbumbsGreedView() {
        router.pushViewControllertoTableViewNavBar(viewController: router.albumsListController())
    }
    
    private func goToAlbumListView() {
        let controller = router.albumsListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToStoryListView() {
        let controller = router.storiesListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToPeopleListView() {
        let controller = router.peopleListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToThingListView() {
        let controller = router.thingsListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToPlaceListView() {
        let controller = router.placesListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
}
