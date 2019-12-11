//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: NSObject, LBAlbumLikePreviewSliderInteractorInput {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!
    
    let albumsManager: SmartAlbumsManager
    
    var currentItems: [SliderItem] {
        return albumsManager.currentItems
    }

    // MARK: - Interactor Input
    
    init(albumsManager: SmartAlbumsManager) {
        self.albumsManager = albumsManager
        
        super.init()
        self.albumsManager.delegates.add(self)
    }

    deinit {
        albumsManager.delegates.remove(self)
    }

    func requestAllItems() {
        albumsManager.requestAllItems()
    }
    
    func reload(types: [MyStreamType]) {
        albumsManager.reload(types: types)
    }
}

//MARK: - SmartAlbumsManagerDelegate

extension LBAlbumLikePreviewSliderInteractor: SmartAlbumsManagerDelegate {
    
    func loadItemsComplete(items: [SliderItem]) {
        output.operationSuccessed(withItems: items)
    }
    
    func loadItemsFailed() {
        output.operationFailed()
    }
}
