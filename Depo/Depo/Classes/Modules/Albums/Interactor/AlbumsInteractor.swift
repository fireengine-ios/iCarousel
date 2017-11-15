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
        guard let remote =  remoteItems as? AlbumService else{
            return
        }
        remote.allAlbums(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self]  albumbs in
            DispatchQueue.main.async {
                var array = [[BaseDataSourceItem]]()
                array.append(albumbs)
                self?.output.getContentWithSuccess(array: array)
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.asyncOperationFail(errorMessage: "fail")
            }
        })
    }
    
    func onAddPhotosToAlbum(selectedAlbumUUID: String){
        output.startAsyncOperation()
        let parameters = AddPhotosToAlbum(albumUUID: selectedAlbumUUID, photos: photos as! [Item])
        PhotosAlbumService().addPhotosToAlbum(parameters: parameters, success: { [weak self] in
            DispatchQueue.main.async {
                print("success")
                self?.output.asyncOperationSucces()
                if let presenter = self?.output as? AlbumSelectionPresenter{
                    presenter.photoAddedToAlbum()
                }
            }
        }) { [weak self] (error) in
            DispatchQueue.main.async {
                print("fail")
                self?.output.asyncOperationFail(errorMessage: "fail")
            }
        }
    }

}
