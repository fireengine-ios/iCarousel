//
//  LocalAlbumInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Photos

class LocalAlbumInteractor: BaseFilesGreedInteractor {
        
    var localStorage = LocalMediaStorage.default
    
    override func getAllItems(sortBy: SortedRules) {
        debugLog("LocalAlbumInteractor getAllItems")
        localStorage.getAllAlbums { [weak self] albums in
            debugLog("LocalAlbumInteractor getAllItems success")

            DispatchQueue.main.async {
                self?.output.getContentWithSuccess(array: [albums])
            }            
        }
    }
    
}
