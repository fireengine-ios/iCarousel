//
//  AlbumDetailAlbumDetailInteractor.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailInteractor: BaseFilesGreedInteractor {

    var album: AlbumItem?
    
    func allItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder) {
        debugLog("AlbumDetailInteractor allItems")
        
        guard let remote = remoteItems as? AlbumDetailService else {
            return
        }
        guard let albumObject = album else {
            return
        }
        
        remote.allItems(albumUUID: albumObject.uuid, sortBy: sortBy, sortOrder: sortOrder, success: { albums in
//            self?.items(items: albums)
            }, fail: {
                debugLog("AlbumDetailInteractor allItems AlbumDetailService allItems fail")
        })
        
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("AlbumDetailInteractor reloadItems")

        guard let albumService = remoteItems as? AlbumDetailService else {
            debugLog("AlbumDetailInteractor reloadItems NOT AlbumDetailService")

            debugPrint("NOT AlbumDetailService")
            return
        }
        
        albumService.currentPage = 0
        nextItems(sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
    override func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("AlbumDetailInteractor nextItems")
        
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        
        guard let albumService = remoteItems as? AlbumDetailService, let unwrapedAlbumUUID = album?.uuid else {
            debugPrint("NOT AlbumDetailService")
            return
        }
        albumService.nextItems(albumUUID: unwrapedAlbumUUID, sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            self?.isUpdating = false
            
            DispatchQueue.main.async {
                if items.isEmpty {
                    self?.output.getContentWithSuccessEnd()
                } else {
                    self?.output.getContentWithSuccess(items: items)
                }
            }
        }, fail: { [weak self] in
            self?.isUpdating = false
            self?.output.asyncOperationFail(errorMessage: nil)
        })
    }
    
    func updateCoverPhotoIfNeeded() {
        if let album = album {
            update(album: album)
        }
    }
    
    fileprivate func update(album: AlbumItem) {
        let service = AlbumDetailService(requestSize: 1)
        service.albumCoverPhoto(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { coverPhoto in
            if album.preview?.uuid != coverPhoto.uuid {
                album.preview = coverPhoto
            }
            ItemOperationManager.default.updatedAlbumCoverPhoto(item: album)
        }) {
            
        }
    }
}
