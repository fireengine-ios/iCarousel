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
        if (selectedItem.fileType == FileType.photoAlbum) {
            
            return
        }
        if (selectedItem.fileType == FileType.musicPlayList) {
            
            return
        }
        
        guard let object = selectedItem as? Item else {
            return
        }
        
        if (selectedItem.fileType == FileType.folder){
            
            let controller = router.filesFromFolder(folder: object, type: .Grid, sortType: .TimeNewOld, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        } else {
            let controller = router.filesDetailViewController(fileObject: object, items: sameTypeItems as! [Item])
            //
            router.pushViewController(viewController: controller)
        }
    }
    
    func createStoryWithItems(_ items: [BaseDataSourceItem]) {
        RouterVC().createStoryName(items: items, needSelectionItems: true)
    }
    
    func showNoFilesToCreateStoryAlert() {
        UIApplication.showErrorAlert(message: TextConstants.searchNoFilesToCreateStoryError)
    }
}
