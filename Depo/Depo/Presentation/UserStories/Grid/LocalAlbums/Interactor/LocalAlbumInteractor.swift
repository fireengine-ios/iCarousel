//
//  LocalAlbumInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

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
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ManualUploadScreen())
        analyticsManager.logScreen(screen: .upload)
        analyticsManager.trackDimentionsEveryClickGA(screen: .upload)
    }
    
}
