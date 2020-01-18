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
            router.back()
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
        router.back()
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        if view.status == .hidden {
            router.back()
        } else {
            dataSource.deleteItems(items: items)
        }
    }
    
    func putBackFromTrashItems(_ items: [Item]) {
        router.back()
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
}
