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
        
        remote.allItems(albumUUID: albumObject.uuid, sortBy: sortBy, sortOrder: sortOrder, success: { (albums) in
//            self?.items(items: albums)
            }, fail: { })
        
    }

}
