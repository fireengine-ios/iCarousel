//
//  FaceImagePhotosDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 12/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImagePhotosDataSourceDelegate: BaseDataSourceForCollectionViewDelegate {
    func didFinishFIRAlbum(operation: ElementTypes, album: Item)
    func didFinishAlbumOperation()
}

final class FaceImagePhotosDataSource: BaseDataSourceForCollectionView {
    
    var album: AlbumItem?
    var item: Item?
    
    private var firDelegate: FaceImagePhotosDataSourceDelegate? {
        delegate as? FaceImagePhotosDataSourceDelegate
    }
    
    override func didHideAlbums(_ albums: [AlbumItem]) {
        notifyOperation(type: .hide, for: albums)
    }

    override func didUnhideAlbums(_ albums: [AlbumItem]) {
        notifyOperation(type: .unhide, for: albums)
    }
    
    override func didMoveToTrashAlbums(_ albums: [AlbumItem]) {
        notifyOperation(type: .moveToTrash, for: albums)
    }
    
    override func putBackFromTrashAlbums(_ albums: [AlbumItem]) {
        notifyOperation(type: .restore, for: albums)
    }

    override func albumsDeleted(albums: [AlbumItem]) {
        notifyOperation(type: .delete, for: albums)
    }
    
    private func notifyOperation(type: ElementTypes, for albums: [AlbumItem]) {
        guard let uuid = albums.first?.uuid, uuid == album?.uuid, let item = item else {
            firDelegate?.didFinishAlbumOperation()
            return
        }
        
        switch type {
        case .hide:
            notifyHideItem()
        case .unhide:
            notifyUnhideItem()
        case .moveToTrash:
            notifyMoveToTrashItem()
        case .restore:
            notifyRestoreItem()
        case .delete:
            break
        default:
            return
        }
        
        firDelegate?.didFinishFIRAlbum(operation: type, album: item)
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
