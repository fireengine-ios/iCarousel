//
//  BaseFilesGreedRouter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedRouter: BaseFilesGreedRouterInput {
    
    let player: MediaPlayer = factory.resolve()
    weak var view: BaseFilesGreedViewController!
    
    func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem]) {
        let router = RouterVC()
        
        if (selectedItem.fileType == .photoAlbum) {
         
            return
        }
        if (selectedItem.fileType == .musicPlayList) {
            
            return
        }
        
        guard let wrapperedItem = selectedItem as? Item else {
            return
        }
        guard let wrapperedArray = sameTypeItems as? [Item] else {
            return
        }
        
        switch selectedItem.fileType {
        
        case .folder:
            let controller = router.filesFromFolder(folder: wrapperedItem)
            router.pushViewControllertoTableViewNavBar(viewController: controller)
        case .audio:
            player.play(list: [wrapperedItem], startAt: 0)
//            SingleSong.default.playWithItem(object: wrappered)
        default:
            let controller = router.filesDetailViewController(fileObject: wrapperedItem, items: wrapperedArray)
            router.pushViewController(viewController: controller)
        }
    }
    
    func showPrint(items: [BaseDataSourceItem]) {
        guard let wrapperedArray = items as? [Item] else {
            return
        }
        let router = RouterVC()
        
        let vc = PrintInitializer.viewController(data: wrapperedArray)
        router.pushViewController(viewController: vc)
    }
    
    func showBack() {
        view.dismiss(animated: true, completion: {})
    }
        
}
