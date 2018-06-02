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
        
        //guard let remote =  remoteItems as? AlbumService else{
        //    return
        //}
        
        //remote.allAlbums(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] (albums) in
          //  self?.items(items: albums)
        //}, fail: { })
    }
    
    override func getAllItems(sortBy: SortedRules) {
        log.debug("AlbumsInteractor getAllItems")

        guard let remote = remoteItems as? AlbumService else {
            return
        }
        remote.allAlbums(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self]  albumbs in
            DispatchQueue.toMain {
                log.debug("AlbumsInteractor getAllItems AlbumService allAlbums success")

                var array = [[BaseDataSourceItem]]()
                array.append(albumbs)
                self?.output.getContentWithSuccess(array: array)
            }
        }, fail: { [weak self] in
            log.debug("AlbumsInteractor getAllItems AlbumService allAlbums fail")

            DispatchQueue.toMain {
                self?.output.asyncOperationFail(errorMessage: "Failed to get albums")
            }
        })
    }
    
    func onAddPhotosToAlbum(selectedAlbumUUID: String) {
        log.debug("AlbumsInteractor onAddPhotosToAlbum")

        output.startAsyncOperation()
        let parameters = AddPhotosToAlbum(albumUUID: selectedAlbumUUID, photos: photos as! [Item])
        PhotosAlbumService().addPhotosToAlbum(parameters: parameters, success: { [weak self] in
            log.debug("AlbumsInteractor onAddPhotosToAlbum PhotosAlbumService addPhotosToAlbum success")

            DispatchQueue.toMain {
                print("success")
                self?.output.asyncOperationSucces()
                
                if let presenter = self?.output as? AlbumSelectionPresenter {
                    presenter.photoAddedToAlbum()
                }
                ItemOperationManager.default.filesAddedToAlbum()
            }
        }) { [weak self] error in
            log.debug("AlbumsInteractor onAddPhotosToAlbum PhotosAlbumService addPhotosToAlbum error")

            DispatchQueue.toMain {
                self?.output.asyncOperationFail(errorMessage: error.description)
            }
        }
    }

}
