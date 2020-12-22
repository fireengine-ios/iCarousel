//
//  LocalAlbumRouter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LocalAlbumRouter: BaseFilesGreedRouter {
        
    override func onItemSelected(selectedItem: BaseDataSourceItem,
                                 sameTypeItems: [BaseDataSourceItem],
                                 type: MoreActionsConfig.ViewType,
                                 sortType: MoreActionsConfig.SortRullesType,
                                 moduleOutput: BaseFilesGreedModuleOutput?) {
        guard let album = selectedItem as? AlbumItem, selectedItem.fileType == .photoAlbum else {
            return
        }
        
        let router = RouterVC()
        let presenter = self.presenter as? LocalAlbumPresenter
        let controller = router.uploadPhotos(rootUUID: album.uuid,
                                             getItems: presenter?.getItems,
                                             saveItems: presenter?.saveItems)
        router.pushViewController(viewController: controller)
    }
    
    override func showBack() {
        view.dismiss(animated: true)
    }
    
}
