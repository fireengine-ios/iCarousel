//
//  AlbumsAlbumsRouter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol AlbumRouterInput {
    func onCreateStory()
    func onCreateAlbum(moduleOutput: SelectNameModuleOutput?)
}

final class AlbumsRouter: BaseFilesGreedRouter, AlbumRouterInput {

    private let router = RouterVC()
    
    override func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem], type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?) {
        if (selectedItem.fileType == .photoAlbum) {
            guard let album = selectedItem as? AlbumItem else {
                return
            }
            
            //need to show photos of the album in grid but in BaseFilesGreedPresenter we have convertation list to grid and grid to list
            let controller = router.albumDetailController(album: album, type: .List, moduleOutput: moduleOutput)

            router.pushViewController(viewController: controller)
        } else {
            super.onItemSelected(selectedItem: selectedItem, sameTypeItems: sameTypeItems, type: type, sortType: sortType, moduleOutput: moduleOutput)
        }
        
    }
    
    func onCreateStory() {
        router.createStoryName()
    }
    
    func onCreateAlbum(moduleOutput: SelectNameModuleOutput?) {
        let controller = router.createNewAlbum(moduleOutput: moduleOutput)
        let nController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: nController)
    }
    
}
