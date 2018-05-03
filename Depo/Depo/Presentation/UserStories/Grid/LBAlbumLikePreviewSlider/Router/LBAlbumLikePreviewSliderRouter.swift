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
    
    private func goToAlbumListView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.albumsListController(moduleOutput: moduleOutput)
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
    
    private func goToThingListView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.thingsListController(moduleOutput: moduleOutput)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    private func goToPlaceListView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.placesListController(moduleOutput: moduleOutput)
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
        case .albums: goToAlbumListView(moduleOutput)
        case .story: goToStoryListView(moduleOutput)
        case .people: goToPeopleListView(moduleOutput)
        case .things: goToThingListView(moduleOutput)
        case .places: goToPlaceListView(moduleOutput)
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
