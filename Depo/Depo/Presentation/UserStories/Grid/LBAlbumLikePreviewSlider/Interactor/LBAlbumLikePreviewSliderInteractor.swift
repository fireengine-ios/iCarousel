//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: NSObject, LBAlbumLikePreviewSliderInteractorInput, ItemOperationManagerViewProtocol {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!

    let dataStorage = LBAlbumLikePreviewSliderDataStorage()
    
    
    //MARK: - Interactor Input
    
    deinit{
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
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
    
    
    //Protocol ItemOperationManagerViewProtocol
    
    func newAlbumCreated(){
        requestAlbumbs()
    }
    
    func albumsDeleted(albums: [AlbumItem]){
        if !albums.isEmpty, !currentItems.isEmpty{
            var newArray = [AlbumItem]()
            let albumsUUIDS = albums.map { $0.uuid }
            for object in currentItems{
                if !albumsUUIDS.contains(object.uuid){
                    newArray.append(object)
                }
            }
            currentItems = newArray
            output.preparedAlbumbs(albumbs: currentItems)
        }
    }
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool{
        if let compairedView = object as? LBAlbumLikePreviewSliderInteractor {
            return compairedView == self
        }
        return false
    }
    
}
