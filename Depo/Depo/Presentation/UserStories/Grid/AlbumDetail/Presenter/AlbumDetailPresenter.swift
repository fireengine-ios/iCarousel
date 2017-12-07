//
//  AlbumDetailAlbumDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailPresenter: BaseFilesGreedPresenter {

    func operationStarted(type: ElementTypes){
        
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        if type == .removeFromAlbum {
            onReloadData()
        }
    }
    
    override var selectedItems: [BaseDataSourceItem] {
        let selectedItems = super.selectedItems
        if selectedItems.count > 0 {
            return selectedItems
        } else if let interactor = interactor as? AlbumDetailInteractor, let album = interactor.album {
            return [album]
        } else {
            return []
        }
    }
    
}
