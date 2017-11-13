//
//  AlbumsAlbumsRouter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsRouter: BaseFilesGreedRouter {

    override func openAlbumDetail(_ album: AlbumItem) {
        let router = RouterVC()
        
        guard let navigation = router.navigationController else {
            return
        }
        
        var viewControllers = navigation.viewControllers
        if viewControllers.count > 0 {
            viewControllers[viewControllers.count - 1] = router.albumDetailController(album: album)
            navigation.viewControllers = viewControllers
        }
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum){
            guard let album = item as? AlbumItem else {
                return
            }
            let controller = router.albumDetailController(album: album)
            router.pushViewController(viewController: controller)
            return
        }
        if (item.fileType == .musicPlayList){
            
            return
        }
    }
    
}
