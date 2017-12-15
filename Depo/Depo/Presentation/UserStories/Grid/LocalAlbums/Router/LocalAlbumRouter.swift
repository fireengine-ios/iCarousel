//
//  LocalAlbumRouter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LocalAlbumRouter: BaseFilesGreedRouter {
        
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem]) {
        let router = RouterVC()
        
        if (selectedItem.fileType == .photoAlbum){
            guard let album = selectedItem as? AlbumItem else {
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
