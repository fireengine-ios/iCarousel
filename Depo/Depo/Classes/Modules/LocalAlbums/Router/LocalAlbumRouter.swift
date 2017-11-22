//
//  LocalAlbumRouter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LocalAlbumRouter: BaseFilesGreedRouter {
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum){
            guard let album = item as? AlbumItem else {
                return
            }
            let controller = router.uploadPhotos(rootUUID: album.uuid)
            router.pushViewController(viewController: controller)
            return
        }
        if (item.fileType == .musicPlayList){
            
            return
        }
    }
    
}
