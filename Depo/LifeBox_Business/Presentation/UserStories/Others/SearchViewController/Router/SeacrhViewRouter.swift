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
        case .musicPlayList:
            return
        case .folder:
            let controller = router.filesFromFolder(folder: wrapperedItem, type: .Grid, sortType: .TimeNewOld, status: .active, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            let player: MediaPlayer = factory.resolve()
            player.play(list: wrapperedArray, startAt: wrapperedArray.index(of: wrapperedItem) ?? 0)
        default:
            let detailModule = router.filesDetailModule(fileObject: wrapperedItem,
                                                        items: wrapperedArray,
                                                        status: .active,
                                                        canLoadMoreItems: false,
                                                        moduleOutput: nil)
            let nController = NavigationController(rootViewController: detailModule.controller)
            router.presentViewController(controller: nController)
        }
    }
    
    func showNoFilesToCreateStoryAlert() {
        UIApplication.showErrorAlert(message: TextConstants.searchNoFilesToCreateStoryError)
    }
}
