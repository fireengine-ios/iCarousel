//
//  BaseFilesGreedRouter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedRouter: BaseFilesGreedRouterInput {
    
    let player: MediaPlayer = factory.resolve()
    
    func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        let router = RouterVC()
        
        if (item.fileType == .photoAlbum) {
         
            return
        }
        if (item.fileType == .musicPlayList) {
            
            return
        }
        
        guard let wrappered = item as? Item else {
            return
        }
        guard let wrapperedArray = data as? [[Item]] else {
            return
        }
        
        switch item.fileType {
        
        case .folder:
            let controller = router.filesFromFolder(folder: wrappered)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            player.play(list: [wrappered], startAt: 0)
//            SingleSong.default.playWithItem(object: wrappered)
        default:
            let controller = router.filesDetailViewController(fileObject: wrappered, from: wrapperedArray)
            router.pushViewController(viewController: controller)
        }
    }
    
    func openAlbumDetail(_ album: AlbumItem) {}
    
}
