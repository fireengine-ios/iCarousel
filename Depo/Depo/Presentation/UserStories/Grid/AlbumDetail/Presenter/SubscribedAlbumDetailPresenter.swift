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
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func didDelete(items: [BaseDataSourceItem]) {
        super.didDelete(items: items)
    
        //return to albums list if this album is empty
        if dataSource.allObjectIsEmpty() {
            albumDetailModuleOutput?.onAlbumDeleted()
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
        setupBackHandler(toOriginal: true)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        if view.status == .hidden {
            setupBackHandler(toOriginal: true)
        } else {
            dataSource.deleteItems(items: items)
        }
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        setupBackHandler(toOriginal: false)
    }
    
    func putBackFromTrashItems(_ items: [Item]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        if let album = (interactor as? AlbumDetailInteractor)?.album, album.uuid == albums.first?.uuid {
            router.back()
        }
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        setupBackHandler(toOriginal: false)
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        setupBackHandler(toOriginal: false)
    }
    
    func deleteItems(items: [Item]) {
        setupBackHandler(toOriginal: true)
    }
    
    private func setupBackHandler(toOriginal: Bool) {
        backHandler = { [weak self] in
            if toOriginal {
                self?.backToOriginController()
            } else {
                self?.router.back()
            }
        }
    }
    
    private func backToOriginController() {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    private func getBackController() -> UIViewController? {
        guard let navVC = (view as? UIViewController)?.navigationController else {
            return nil
        }
        
        if let hiddenBin = navVC.viewControllers.first(where: { $0 is HiddenPhotosViewController }) {
            return hiddenBin
        } else if let segmentedController = navVC.viewControllers.first(where: { $0 is SegmentedController }) {
            return segmentedController
        }
        return nil
    }
}
