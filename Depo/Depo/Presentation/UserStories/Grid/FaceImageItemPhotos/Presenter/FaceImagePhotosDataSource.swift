//
//  FaceImagePhotosDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 12/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosDataSource: BaseDataSourceForCollectionView {
    
    var album: AlbumItem?
    var item: Item?
    
    override func didHideAlbums(_ albums: [AlbumItem]) {
        notifyHideItem()
        delegate?.didDelete(items: albums)
    }

    override func didUnhideAlbums(_ albums: [AlbumItem]) {
        notifyUnhideItem()
        delegate?.didDelete(items: albums)
    }
    
    override func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        notifyMoveToTrashItem()
        delegate?.didDelete(items: albums)
    }
    
    override func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        notifyRestoreItem()
        delegate?.didDelete(items: albums)
    }

    override func albumsDeleted(albums: [AlbumItem]) {
        delegate?.didDelete(items: albums)
    }

    private func notifyHideItem() {
        if let peopleItem = item as? PeopleItem {
            ItemOperationManager.default.didHidePeople(items: [peopleItem])
        } else if let placesItem = item as? PlacesItem {
            ItemOperationManager.default.didHidePlaces(items: [placesItem])
        } else if let thingsitem = item as? ThingsItem {
            ItemOperationManager.default.didHideThings(items: [thingsitem])
        }
    }
    
    private func notifyUnhideItem() {
        if let peopleItem = item as? PeopleItem {
            ItemOperationManager.default.didUnhidePeople(items: [peopleItem])
        } else if let placesItem = item as? PlacesItem {
            ItemOperationManager.default.didUnhidePlaces(items: [placesItem])
        } else if let thingsitem = item as? ThingsItem {
            ItemOperationManager.default.didUnhideThings(items: [thingsitem])
        }
    }
    
    private func notifyRestoreItem() {
        if let peopleItem = item as? PeopleItem {
            ItemOperationManager.default.putBackFromTrashPeople(items: [peopleItem])
        } else if let placesItem = item as? PlacesItem {
            ItemOperationManager.default.putBackFromTrashPlaces(items: [placesItem])
        } else if let thingsitem = item as? ThingsItem {
            ItemOperationManager.default.putBackFromTrashThings(items: [thingsitem])
        }
    }
    
    private func notifyMoveToTrashItem() {
        if let peopleItem = item as? PeopleItem {
            ItemOperationManager.default.didMoveToTrashPeople(items: [peopleItem])
        } else if let placesItem = item as? PlacesItem {
            ItemOperationManager.default.didMoveToTrashPlaces(items: [placesItem])
        } else if let thingsitem = item as? ThingsItem {
            ItemOperationManager.default.didMoveToTrashThings(items: [thingsitem])
        }
    }
}
