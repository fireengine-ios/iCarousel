//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: LBAlbumLikePreviewSliderInteractorInput {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!

    let dataStorage = LBAlbumLikePreviewSliderDataStorage()
    
    
    //MARK: - Interactor Input
    
    var currentItems: [AlbumItem] {
        set {
            dataStorage.storedItems = newValue
        }
        get {
            return dataStorage.storedItems
        }
    }
    
    func requestAlbumbs() {
        let albumService = AlbumService(requestSize: 9999)
        albumService.allAlbums(sortBy: .date, sortOrder: .asc, success: { albumbs in
            DispatchQueue.main.async { [weak self] in
                self?.currentItems = albumbs
                self?.output.preparedAlbumbs(albumbs: albumbs)
                self?.output.operationSuccessed()
            }
        }, fail: {
            DispatchQueue.main.async { [weak self] in
                self?.output.operationFailed()
            }
            
        })
    }
    
}
