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
    
    override func didDelete(items: [BaseDataSourceItem]) {
        super.didDelete(items: items)
    
        //return to albums list if this album is empty
        if dataSource.allObjectIsEmpty() {
            albumDetailModuleOutput?.onAlbumDeleted()
            back()
        }
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
    
    func didHideItems(_ items: [WrapData]) {
        dataSource.deleteItems(items: items)
    }

    func didUnhideItems(_ items: [WrapData]) {
        dataSource.deleteItems(items: items)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        dataSource.deleteItems(items: items)
    }
    
    func putBackFromTrashItems(_ items: [Item]) {
        dataSource.deleteItems(items: items)
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        back()
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        back()
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        back()
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        back()
    }
    
    private func back() {
        (router as? AlbumDetailRouter)?.back()
    }
}
