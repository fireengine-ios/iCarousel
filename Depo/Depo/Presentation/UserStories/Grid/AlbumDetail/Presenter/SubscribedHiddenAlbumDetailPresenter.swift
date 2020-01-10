//
//  SubscribedHiddenAlbumDetailPresenter.swift
//  Depo
//
//  Created by Alex on 12/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class SubscribedHiddenAlbumDetailPresenter: AlbumDetailPresenter {
    
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
extension SubscribedHiddenAlbumDetailPresenter: ItemOperationManagerViewProtocol {
    
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
    
    func didMoveToTrashItems(_ items: [Item]) {
        view.disableRefresh()
    }
    
    func didUnhideItems(_ items: [WrapData]) {
        view.disableRefresh()
        dataSource.deleteItems(items: items)
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        guard let router = self.router as? AlbumDetailRouter else {
            return
        }
        
        router.back()
    }
    
}
