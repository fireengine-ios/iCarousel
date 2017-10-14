//
//  AlbumsAlbumsInteractor.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsInteractor: BaseFilesGreedInteractor {
    
    var photos: [BaseDataSourceItem]?

    func allItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder) {
        
        guard let remote =  remoteItems as? AlbumService else{
            return
        }
        
        remote.allAlbums(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] (albums) in
          //  self?.items(items: albums)
        }, fail: { })
    }
    
    func onAddPhotosToAlbum(selectedAlbum: BaseDataSourceItem){
        output.startAsyncOperation()
        let parameters = AddPhotosToAlbum(albumUUID: selectedAlbum.uuid, photos: photos as! [Item])
        PhotosAlbumService().addPhotosToAlbum(parameters: parameters, success: {
            DispatchQueue.main.async { [weak self] in
                print("success")
                self?.output.asyncOperationSucces()
            }
        }) { (error) in
            DispatchQueue.main.async { [weak self] in
                print("fail")
                self?.output.asyncOperationFail(errorMessage: "fail")
            }
        }
    }

}
