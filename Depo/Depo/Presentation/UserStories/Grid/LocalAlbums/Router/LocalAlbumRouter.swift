//
//  LocalAlbumRouter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LocalAlbumRouter: BaseFilesGreedRouter {
        
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]], type: MoreActionsConfig.ViewType, moduleOutput: BaseFilesGreedModuleOutput?) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum){
            guard let album = item as? AlbumItem else {
                return
            }
            let controller = router.uploadPhotos(rootUUID: album.uuid)

            view.navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    override func showBack() {
        view.dismiss(animated: true, completion: {})
    }
    
}
