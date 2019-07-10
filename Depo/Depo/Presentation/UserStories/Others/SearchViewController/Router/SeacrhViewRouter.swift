//
//  SeacrhViewRouter.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SeacrhViewRouter: SearchViewRouterInput {

    private let router = RouterVC()
    
    func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem]) {
        guard let wrapperedItem = selectedItem as? Item,
              let wrapperedArray = sameTypeItems as? [Item] else {
            return
        }
        
        switch wrapperedItem.fileType {
        case .photoAlbum, .musicPlayList:
            return
        case .folder:
            let controller = router.filesFromFolder(folder: wrapperedItem, type: .Grid, sortType: .TimeNewOld, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            let player: MediaPlayer = factory.resolve()
            player.play(list: wrapperedArray, startAt: wrapperedArray.index(of: wrapperedItem) ?? 0)
        default:
            let controller = router.filesDetailViewController(fileObject: wrapperedItem, items: wrapperedArray)
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
        }
    }
    
    func createStoryWithItems(_ items: [BaseDataSourceItem]) {
        guard let items = items as? [Item] else {
            let error = CustomErrors.text("An error has occured while images converting.")
            UIApplication.showErrorAlert(message: error.localizedDescription)
            return
        }
        
        let router = RouterVC()
        let controller = router.createStory(items: items)
        router.pushViewController(viewController: controller)
    }
    
    func showNoFilesToCreateStoryAlert() {
        UIApplication.showErrorAlert(message: TextConstants.searchNoFilesToCreateStoryError)
    }
    
    func openFaceImageItems(category: SearchCategory) {
        switch category {
        case .people:
            let controller = router.peopleListController()
            router.pushViewController(viewController: controller)
        case .things:
            let controller = router.thingsListController()
            router.pushViewController(viewController: controller)
        default:
            return
        }
    }
    
    func openFaceImageItemPhotos(item: Item, album: AlbumItem) {
        let controller = router.imageFacePhotosController(album: album, item: item, moduleOutput: nil, isSearchItem: true)
        router.pushViewController(viewController: controller)
    }
    
    func openAlbum(item: AlbumItem) {
        let controller = router.albumDetailController(album: item, type: .List, moduleOutput: nil)
        router.pushViewController(viewController: controller)
    }
}
