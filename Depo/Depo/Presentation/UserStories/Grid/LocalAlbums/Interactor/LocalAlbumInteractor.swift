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
        self.output.getContentWithSuccess(array: [localStorage.getAllAlbums()])
    }
    
}


