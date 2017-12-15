//
//  SeacrhViewRouter.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SeacrhViewRouter: SearchViewRouterInput {
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        let router = RouterVC()
        if (item.fileType == FileType.photoAlbum){
            
            return
        }
        if (item.fileType == FileType.musicPlayList){
            
            return
        }
        
        guard let object = item as? Item else{
            return
        }
        
        if (item.fileType == FileType.folder){
            
            let controller = router.filesFromFolder(folder: object, type: .Grid, moduleOutput: nil)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        }else{
            let controller = router.filesDetailViewController(fileObject: object, from: data as! [[Item]])
            //
            router.pushViewController(viewController: controller)
        }
        
    }
}
