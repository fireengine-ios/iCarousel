//
//  AlbumsAlbumsRouter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsRouter: BaseFilesGreedRouter {
    
    weak var presenter: AlbumsPresenter?
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem]) {
        let router = RouterVC()
        
        if (selectedItem.fileType == .photoAlbum){
            guard let album = selectedItem as? AlbumItem else {
                return
            }
            let controller = router.albumDetailController(album: album, moduleOutput: presenter)
            router.pushViewController(viewController: controller)
            return
        }
    }
    
}
