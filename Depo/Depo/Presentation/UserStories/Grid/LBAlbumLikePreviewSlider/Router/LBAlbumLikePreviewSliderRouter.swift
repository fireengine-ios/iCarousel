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
    
    private func goToInstaPickView(_ moduleOutput: LBAlbumLikePreviewSliderModuleInput?) {
        let controller = router.analyzesHistoryController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
        
//        let imagesUrls = [
//            URL(string: "https://im0-tub-ua.yandex.net/i?id=70da0b4b7101ea480e4086c928074be9&n=13")!,
//            URL(string: "https://www.telegraph.co.uk/content/dam/news/2016/09/08/107667228_beech-tree-NEWS_trans_NvBQzQNjv4BqplGOf-dgG3z4gg9owgQTXEmhb5tXCQRHAvHRWfzHzHk.jpg")!,
//            URL(string: "https://im0-tub-ua.yandex.net/i?id=70da0b4b7101ea480e4086c928074be9&n=13")!,
//            URL(string: "https://www.telegraph.co.uk/content/dam/news/2016/09/08/107667228_beech-tree-NEWS_trans_NvBQzQNjv4BqplGOf-dgG3z4gg9owgQTXEmhb5tXCQRHAvHRWfzHzHk.jpg")!]
//
//        let topTexts = [TextConstants.instaPickAnalyzingText_0,
//                        TextConstants.instaPickAnalyzingText_1,
//                        TextConstants.instaPickAnalyzingText_2,
//                        TextConstants.instaPickAnalyzingText_3,
//                        TextConstants.instaPickAnalyzingText_4]
//
//        let bottomText = TextConstants.instaPickAnalyzingBottomText
//        if let currentController = UIApplication.topController() {
//            //TODO: INSTAPICK pass selected images' urls and text somewhere else
//            let controller = InstaPickProgressPopup.createPopup(with: imagesUrls, topTexts: topTexts, bottomText: bottomText)
//
//            currentController.present(controller, animated: true, completion: nil)
//        }
    }
    
    private func goToHiddenView() {
        let controller = router.hiddenPhotosViewController()
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
        case .instaPick: goToInstaPickView(moduleOutput)
        case .album, .firAlbum:
            guard let albumItem = item.albumItem else {
                break
            }
            goToAlbumDetailView(album: albumItem)
        case .hidden: goToHiddenView()
        }
    }
    
    func goToAlbumbsGreedView() {
        router.pushViewControllertoTableViewNavBar(viewController: router.albumsListController())
    }

}
