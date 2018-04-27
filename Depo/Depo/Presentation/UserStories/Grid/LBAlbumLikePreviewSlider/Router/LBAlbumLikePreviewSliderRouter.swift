//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderRouter {
    
    let router = RouterVC()
    
    // MARK: - Utility methods
    
    private func goToAlbumDetailView(album: AlbumItem) {
        let controller = router.albumDetailController(album: album, type: .List, moduleOutput: nil)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToAlbumListView() {
        let controller = router.albumsListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToStoryListView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.storiesListController(moduleOutput: moduleOutput)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToPeopleListView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.peopleListController(moduleOutput: moduleOutput)
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

// MARK: - LBAlbumLikePreviewSliderRouterInput

extension LBAlbumLikePreviewSliderRouter: LBAlbumLikePreviewSliderRouterInput {
    
    func onItemSelected(_ item: SliderItem, moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        guard let type = item.type else {
            return
        }
        
        switch type {
        case .albums: goToAlbumListView()
        case .story: goToStoryListView(moduleOutput)
        case .people: goToPeopleListView(moduleOutput)
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

}
