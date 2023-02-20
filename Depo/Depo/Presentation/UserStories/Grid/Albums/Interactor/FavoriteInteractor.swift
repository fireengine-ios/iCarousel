//
//  FavoriteInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 12.01.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

class FavoriteInteractor: BaseFilesGreedInteractor {
    
    private lazy var service = ForYouService()
    private lazy var favoriteService = SearchService()

    override func getAllItems(sortBy: SortedRules) {
        debugLog("CollageInteractor getAllItems")
        
        getFavorites()
    }
    
    private func getFavorites(completion: (() -> Void)? = nil) {
        debugLog("ForYou getFavorites")
        
        let serchParam = SearchByFieldParameters(fieldName: .favorite,
                                                 fieldValue: .favorite,
                                                 sortBy: .name,
                                                 sortOrder: .desc,
                                                 page: 0,
                                                 size: 10)
        
        favoriteService.searchByField(param: serchParam, success: { [weak self] response in
            guard let resultResponse = response as? SearchResponse else {
                return
            }
            
            let list = resultResponse.list.filter({ $0.contentType == "image/jpeg" || $0.contentType == "image/png" || $0.contentType == "image/heic"
                                                 || $0.contentType == "video/mp4" || $0.contentType == "video/quicktime" })
            
            //self?.output.getFavorites(data: list.map { WrapData(remote: $0) })
            
            var array = [[BaseDataSourceItem]]()
            array.append(list.map { WrapData(remote: $0) })
            self?.output.getContentWithSuccess(array: array)
            
        }, fail: { errorResponse in
            errorResponse.showInternetErrorGlobal()
        })
    }
    
    private func getCollages() {
        debugLog("ForYou getCollages")
        service.forYouCollages() { [weak self] result in
            switch result {
            case .success(let response):
                var array = [[BaseDataSourceItem]]()
                array.append(response.fileList)
                self?.output.getContentWithSuccess(array: array)
            case .failed:
                break
            }
        }
    }
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.FavoritesScreen())
        analyticsManager.logScreen(screen: .favorites)
        analyticsManager.trackDimentionsEveryClickGA(screen: .favorites)
    }
}
