//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderRouter: LBAlbumLikePreviewSliderRouterInput {
    
    let router = RouterVC()
    
    func goToAlbumbsGreedView() {
        router.pushViewControllertoTableViewNavBar(viewController: router.albumsListController())
    }

    func goToAlbumDetailView(album: AlbumItem) {
        let controller = router.albumDetailController(album: album, type: .List, moduleOutput: nil)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    func goToAlbumListView() {
        let controller = router.albumsListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    func goToStoryListView() {
        let controller = router.storiesListController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    func goToPeopleListView() {
        
    }
    
    func goToThingListView() {
        
    }
    
    func goToPlaceListView() {
        
    }
    
}
