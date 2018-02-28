//
//  SearchViewInteractor.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewInteractor: SearchViewInteractorInput {
    
    weak var output: SearchViewInteractorOutput?
    
    var alertSheetConfig: AlertFilesActionsSheetInitialConfig?
    
    var bottomBarOriginalConfig: EditingBarConfig?
    
    let remoteItems: RemoteSearchService
    let recentSearches: RecentSearchesService
    
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    
    init(remoteItems: RemoteSearchService, recentSearches: RecentSearchesService) {
        self.remoteItems = remoteItems
        self.recentSearches = recentSearches
    }
    
    func viewIsReady() {
        output?.setRecentSearches(recentSearches.searches)
        getDefaultSuggetion(text: "")
    }
    
    func searchItems(by searchText: String, item: SuggestionObject?, sortBy: SortType, sortOrder: SortOrder) {
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
             success: { [weak self] (items) in
                guard let `self` = self else { return }
                self.items(items: items)
                DispatchQueue.main.async {
                    if let searchItem = item {
                        self.recentSearches.addSearch(item: searchItem)
                    } else {
                        self.recentSearches.addSearch(searchText)
                    }
                    self.output?.setRecentSearches(self.recentSearches.searches)
                    self.output?.endSearchRequestWith(text: searchText)
                }
            }, fail: { [weak self] in
                DispatchQueue.main.async {
                    self?.output?.failedSearch()
                }
        })
    }
    
    private func items(items: [Item]) {
        DispatchQueue.main.async { [weak self] in
            if let wraperdOutput = self?.output {
                wraperdOutput.getContentWithSuccess(items: items)
            }
        }
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder ) {
        remoteItems.nextItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
                              success: { [weak self] (items) in
                                self?.items(items: items)
            }, fail: { })
    }
    
    func allItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder) {
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] (items) in
            self?.items(items: items)
            }, fail: { })
    }
    
    func needShowNoFileView() -> Bool {
        return true
    }
    
    func getSuggetion(text: String) {
        remoteItems.getSuggestion(text: text, success: { (suggestList) in
            DispatchQueue.main.async { [weak self] in
                if let wrapOutput = self?.output {
                    wrapOutput.successWithSuggestList(list: suggestList.filter {$0.text != nil})
                }
            }
        }, fail: { (_) in
        })
    }
    
    func getDefaultSuggetion(text: String) {
        getSuggetion(text: text)
    }
    
    func clearRecentSearches() {
        recentSearches.clearAll()
        output?.setRecentSearches(recentSearches.searches)
    }
    
    func openFaceImageForSuggest(item: SuggestionObject) {
        saveSearch(item: item)
        getAlbumItem(forSearchItem: item)
    }
    
    func openFaceImageForSearch(item: BaseDataSourceItem?) {
        if let suggest = suggestionFrom(item: item) {
            getAlbumItem(forSearchItem: suggest)
        } else {
            output?.failedGetAlbum()
        }
    }
    
    func saveSearch(item: SuggestionObject) {
        recentSearches.addSearch(item: item)
        output?.setRecentSearches(recentSearches.searches)
    }
    
    private func getAlbumItem(forSearchItem item: SuggestionObject) {
        guard let id = item.info?.id, let type = item.type else {
            output?.failedGetAlbum()
            return
        }
        
        switch type {
        case .people:
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] albumResponse in
                
                let peopleItemResponse = PeopleItemResponse()
                peopleItemResponse.id = id
                peopleItemResponse.name = item.info?.name ?? ""
                
                DispatchQueue.main.async {
                    self?.output?.getAlbum(albumItem: AlbumItem(remote: albumResponse),
                                           forItem: PeopleItem(response: peopleItemResponse))
                }
                }, fail: { [weak self] fail in
                    DispatchQueue.main.async {
                        self?.output?.failedGetAlbum()
                    }
            })
        case .thing:
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] albumResponse in
                
                let thingItemResponse = ThingsItemResponse()
                thingItemResponse.id = id
                thingItemResponse.name = item.info?.name ?? ""
                
                DispatchQueue.main.async {
                    self?.output?.getAlbum(albumItem: AlbumItem(remote: albumResponse),
                                           forItem: ThingsItem(response: thingItemResponse))
                }
                }, fail:  { [weak self] fail in
                    DispatchQueue.main.async {
                        self?.output?.failedGetAlbum()
                    }
            })
        case .place:
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] albumResponse in
                
                let placeItemResponse = PlacesItemResponse()
                placeItemResponse.id = id
                placeItemResponse.name = item.info?.name ?? ""
                
                DispatchQueue.main.async {
                    self?.output?.getAlbum(albumItem: AlbumItem(remote: albumResponse),
                                           forItem: PlacesItem(response: placeItemResponse))
                }
                }, fail:  { [weak self] fail in
                    DispatchQueue.main.async {
                        self?.output?.failedGetAlbum()
                    }
            })
        default:
            output?.failedGetAlbum()
            break
        }
    }
    
    private func suggestionFrom(item: BaseDataSourceItem?) -> SuggestionObject? {
        guard let item = item else {
            return nil
        }
        
        let suggest = SuggestionObject()
        let info = SuggestionInfo()
        
        switch item.fileType {
        case .faceImage(.people):
            guard let peopleItem = item as? PeopleItem else {
                return nil
            }
            suggest.type = .people
            info.id = peopleItem.responseObject.id
            info.name = peopleItem.responseObject.name
            
        case .faceImage(.things):
            guard let thingsItem = item as? ThingsItem else {
                return nil
            }
            suggest.type = .thing
            info.id = thingsItem.responseObject.id
            info.name = thingsItem.responseObject.name
            
        case .faceImage(.places):
            guard let placesItem = item as? PlacesItem else {
                return nil
            }
            suggest.type = .place
            info.id = placesItem.responseObject.id
            info.name = placesItem.responseObject.name
            
        default:
            return nil
        }
        
        suggest.info = info
        return suggest
    }
    
    var alerSheetMoreActionsConfig: AlertFilesActionsSheetInitialConfig? {
        return alertSheetConfig        
    }
    
    var bottomBarConfig: EditingBarConfig? {
        set {
            bottomBarOriginalConfig = newValue
        }
        get {
            return bottomBarOriginalConfig
        }
    }
}
