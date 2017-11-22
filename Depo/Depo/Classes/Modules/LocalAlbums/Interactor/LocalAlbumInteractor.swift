//
//  LocalAlbumInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Photos

class LocalAlbumInteractor: BaseFilesGreedInteractor {
    
    var photos: [BaseDataSourceItem]?
    
    var localStorage = LocalMediaStorage.default
    
    override func getAllItems(sortBy: SortedRules) {
        self.output.getContentWithSuccess(array: [localStorage.getAllAlbums()])
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


