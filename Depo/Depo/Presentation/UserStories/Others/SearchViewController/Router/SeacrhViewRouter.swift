//
//  SeacrhViewRouter.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SeacrhViewRouter: SearchViewRouterInput {

    func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem]) {
        let router = RouterVC()
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
            router.pushViewController(viewController: controller)
        }
    }
    
    func createStoryWithItems(_ items: [BaseDataSourceItem]) {
        RouterVC().createStoryName(items: items, needSelectionItems: true, isFavorites: false)
    }
    
    func showNoFilesToCreateStoryAlert() {
        UIApplication.showErrorAlert(message: TextConstants.searchNoFilesToCreateStoryError)
    }
}
