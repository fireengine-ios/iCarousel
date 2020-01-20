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
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        if view.status == .hidden {
            guard let controller = getBackController() else {
                return
            }
            router.back(to: controller)
        } else {
            dataSource.deleteItems(items: items)
        }
    }
    
    func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func putBackFromTrashItems(_ items: [Item]) {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    func didHideAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func didUnhideAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        router.back()
    }
    
    func deleteItems(items: [Item]) {
        guard let controller = getBackController() else {
            return
        }
        router.back(to: controller)
    }
    
    private func getBackController() -> UIViewController? {
        let navVC = (view as? UIViewController)?.navigationController
        let destinationIndex = navVC?.viewControllers.firstIndex(where: {
            ($0 is HiddenPhotosViewController) || ($0 is SegmentedController)
        })
        guard let index = destinationIndex, let destination = navVC?.viewControllers[safe: index] else {
            return nil
        }
        
        return destination
    }
}
