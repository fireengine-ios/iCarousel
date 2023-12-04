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
    
    override func getAllItems(sortBy: SortedRules) {
        
        guard let remote = remoteItems as? FavoriteService else {
            return
        }
        
        remote.currentPage = 0
        nextItems(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, newFieldValue: .favorite)
    }
    
    override func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("StoriesInteractor getAllItems")
        
        guard let remote = remoteItems as? FavoriteService else {
            return
        }
        
        remote.nextItems(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] favorites in
            DispatchQueue.main.async {
                if favorites.isEmpty {
                    self?.output.getContentWithSuccessEnd()
                } else {
                    var array = [[BaseDataSourceItem]]()
                    array.append(favorites)
                    self?.output.getContentWithSuccessWithPaginiation(array: array)
                }
            }}, fail: { [weak self] in
                DispatchQueue.main.async {
                    self?.output.asyncOperationFail(errorMessage: "fail")
                }
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
