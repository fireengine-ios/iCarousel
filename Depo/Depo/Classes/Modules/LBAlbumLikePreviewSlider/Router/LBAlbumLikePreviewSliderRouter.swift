//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderRouter: LBAlbumLikePreviewSliderRouterInput {
    
    func goToAlbumbsGreedView() {
        let globalRouter = RouterVC()
        globalRouter.pushViewController(viewController: globalRouter.albumsListController())
    }

    func goToAlbumDetailView(album: AlbumItem){
        let router = RouterVC()
        let controller = router.albumDetailController(album: album)
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
}
