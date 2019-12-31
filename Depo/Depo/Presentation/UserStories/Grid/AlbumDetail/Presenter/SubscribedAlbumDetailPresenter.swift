//
//  SubscribedAlbumDetailPresenter.swift
//  Depo
//
//  Created by Alex on 12/31/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class SubscribedAlbumDetailPresenter: AlbumDetailPresenter {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()

        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
}

//MARK: - ItemOperationManagerViewProtocol related
extension SubscribedAlbumDetailPresenter: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        guard
            let presenter = object as? AlbumDetailPresenter,
            let view = presenter.view as? AlbumDetailViewController,
            let albumId = view.album?.uuid,

            let selfView = self.view as? AlbumDetailViewController,
            let selfAlbumId = selfView.album?.uuid
        else {
            return false
        }
        
        return albumId == selfAlbumId
    }
    
    func didHide(items: [WrapData]) {
        dataSource.deleteItems(items: items)
    }

}
