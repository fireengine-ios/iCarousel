//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderRouter: LBAlbumLikePreviewSliderRouterInput {
    
    let router = RouterVC()
    
    func onItemSelected(type: MyStreamType?) {
        guard let type = type else {
            return
        }
        switch type {
        case .album: goToAlbumListView()
        case .story: goToStoryListView()
        case .people: goToPeopleListView()
        case .things: goToThingListView()
        case .places: goToPlaceListView()
        }
    }
    
    func goToAlbumbsGreedView() {
        router.pushViewControllertoTableViewNavBar(viewController: router.albumsListController())
    }

    private func goToAlbumDetailView(album: AlbumItem) {
        let controller = router.albumDetailController(album: album, type: .List, moduleOutput: nil)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
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
        
    }
    
    private func goToThingListView() {
        
    }
    
    private func goToPlaceListView() {
        
    }
    
}
