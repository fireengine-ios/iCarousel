//
//  AlbumsAlbumsRouter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsRouter: BaseFilesGreedRouter {
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]], type: MoreActionsConfig.ViewType, moduleOutput: BaseFilesGreedModuleOutput?) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum){
            guard let album = item as? AlbumItem else {
                return
            }
            
            let controller = router.albumDetailController(album: album, type: type, moduleOutput: moduleOutput)

            router.pushViewController(viewController: controller)
            return
        }
    }
    
}
