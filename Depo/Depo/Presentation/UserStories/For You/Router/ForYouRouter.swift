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
    private lazy var instaPickRoutingService = InstaPickRoutingService()
    
    func navigateToSeeAll(for view: ForYouSections) {
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
        case .story:
            let stories = router.storiesListController()
            router.pushViewController(viewController: stories)
        case .hidden:
            let hidden = router.hiddenPhotosViewController()
            router.pushViewController(viewController: hidden)
        case .photopick:
            let photopick = router.analyzesHistoryController()
            router.pushViewController(viewController: photopick)
        default:
            break
        }
    }
    
    func navigateToFaceImage() {
        let vc = router.faceImage
        router.pushViewController(viewController: vc)
    }
    
    func navigateToCreate(for view: ForYouSections) {
        switch view {
        case .albums:
            let createAlbum = router.createNewAlbum()
            router.pushViewController(viewController: createAlbum)
        case .photopick:
            let photopick = router.analyzesHistoryController()
            router.pushViewController(viewController: photopick)
        case .story:
            let createStory = router.createStory(navTitle: "")
            router.pushViewController(viewController: createStory)
        default:
            return
        }
    }
    
    func navigateToItemDetail(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?) {
        let albumItem = AlbumItem(remote: album)
        let vc = router.imageFacePhotosController(album: albumItem, item: item, status: .active, moduleOutput: nil, faceImageType: faceImageType)
        router.pushViewController(viewController: vc)
    }
    
    func navigateToAlbumDetail(album: AlbumItem) {
        let albumVC = router.albumDetailController(album: album, type: .List, status: .active, moduleOutput: nil)
        router.pushViewController(viewController: albumVC)
    }
    
    func navigateToItemPreview(item: WrapData, items: [WrapData]) {
        let detailModule = router.filesDetailModule(fileObject: item,
                                                      items: items,
                                                      status: item.status,
                                                      canLoadMoreItems: false,
                                                      moduleOutput: nil)
        
        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController)
    }
    
    func navigateToThrowbackDetail(item: ThrowbackDetailsData) {
        let uuids = item.fileList.compactMap { $0?.uuid }
        let vc = router.tbmaticPhotosContoller(uuids: uuids)
        self.router.presentViewController(controller: vc)
    }
    
    func displayAlbum(item: AlbumItem) {
        let albumVC = router.albumDetailController(album: item, type: .List, status: .active, moduleOutput: nil)
        router.pushViewController(viewController: albumVC)
    }

    func displayItem(item: WrapData) {
        let controller = PVViewerController.with(item: item)
        let navController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: navController)
    }
    
    func showSavedItem(item: WrapData) {
        let detailModule = router.filesDetailModule(fileObject: item,
                                                    items: [item],
                                                    status: .active,
                                                    canLoadMoreItems: false,
                                                    moduleOutput: nil)

        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController)
    }
    
    func showFullQuota() {
        router.showFullQuotaPopUp()
    }
}

