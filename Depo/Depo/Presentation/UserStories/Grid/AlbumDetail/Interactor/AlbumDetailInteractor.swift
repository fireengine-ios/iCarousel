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
        log.debug("AlbumDetailInteractor allItems")
        
        guard let remote =  remoteItems as? AlbumDetailService else{
            return
        }
        guard let albumObject = album else {
            return
        }
        
        remote.allItems(albumUUID: albumObject.uuid,
                        sortBy: sortBy, sortOrder: sortOrder, success: { albums in
                            log.debug("AlbumDetailInteractor allItems AlbumDetailService allItems success")

//            self?.items(items: albums)
            }, fail: {
                log.debug("AlbumDetailInteractor allItems AlbumDetailService allItems fail")
        })
        
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        log.debug("AlbumDetailInteractor reloadItems")

        guard let albumService = remoteItems as? AlbumDetailService else {
            log.debug("AlbumDetailInteractor reloadItems NOT AlbumDetailService")

            debugPrint("NOT AlbumDetailService")
            return
        }
        albumService.currentPage = 0
        nextItems(sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
    override func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        log.debug("AlbumDetailInteractor nextItems")
        
        guard let albumService = remoteItems as? AlbumDetailService, let unwrapedAlbumUUID = album?.uuid else {
            debugPrint("NOT AlbumDetailService")
            return
        }
        albumService.nextItems(albumUUID: unwrapedAlbumUUID, sortBy: sortBy, sortOrder: sortOrder,
                               success: { [weak self] items in
                                log.debug("AlbumDetailInteractor nextItems AlbumDetailService nextItems success")

                                DispatchQueue.main.async {
                                    if items.count == 0 {
                                        self?.output.getContentWithSuccessEnd()
                                    } else {
                                        self?.output.getContentWithSuccess(items: items)
                                    }
                                }
            }, fail: { [weak self] in
                log.debug("AlbumDetailInteractor nextItems AlbumDetailService nextItems fail")

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
                ItemOperationManager.default.updatedAlbumCoverPhoto(item: album)
            }
        }) {
            
        }
    }
}
