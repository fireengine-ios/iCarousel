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
        
        guard let remote =  remoteItems as? AlbumDetailService else{
            return
        }
        guard let albumObject = album else {
            return
        }
        
        remote.allItems(albumUUID: albumObject.uuid,
                        sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] (albums) in
//            self?.items(items: albums)
            }, fail: { })
        
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        guard let albumService = remoteItems as? AlbumDetailService, let unwrapedAlbumUUID = album?.uuid else {
            debugPrint("NOT AlbumDetailService")
            return
        }
        albumService.currentPage = 0
        nextItems(sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
    override func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        
        guard let albumService = remoteItems as? AlbumDetailService, let unwrapedAlbumUUID = album?.uuid else {
            debugPrint("NOT AlbumDetailService")
            return
        }
        albumService.nextItems(albumUUID: unwrapedAlbumUUID, sortBy: sortBy, sortOrder: sortOrder,
                               success: { [weak self] items in
                                DispatchQueue.main.async {
                                    if items.count == 0 {
                                        self?.output.getContentWithSuccessEnd()
                                    } else {
                                        self?.output.getContentWithSuccess()
                                    }
                                }
            }, fail: { [weak self] in
                self?.output.asyncOperationFail(errorMessage: nil)
        })
    }
}
