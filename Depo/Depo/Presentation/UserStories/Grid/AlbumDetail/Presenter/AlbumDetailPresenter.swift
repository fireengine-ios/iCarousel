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
    
}
