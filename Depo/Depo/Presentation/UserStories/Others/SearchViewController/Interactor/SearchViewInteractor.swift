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
    
    func openFaceImage(forItem item: SuggestionObject) {
        saveSearch(item: item)
        getAlbumItem(forSearchItem: item)
    }
    
    func saveSearch(item: SuggestionObject) {
        recentSearches.addSearch(item: item)
        output?.setRecentSearches(recentSearches.searches)
    }
    
    private func getAlbumItem(forSearchItem item: SuggestionObject) {
        guard let id = item.info?.id, let type = item.type else {
            return
        }
        
        if type == .people {            
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] albumResponse in
                
                let peopleItemResponse = PeopleItemResponse()
                peopleItemResponse.id = id
                peopleItemResponse.name = item.info?.name

                DispatchQueue.main.async {
                    self?.output?.getAlbum(albumItem: AlbumItem(remote: albumResponse),
                                           forItem: PeopleItem(response: peopleItemResponse))
                }
            }, fail: { fail in
                DispatchQueue.main.async {
                    self.output?.failedGetAlbum()
                }
            })
        } else if type == .thing {
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] albumResponse in
                
                let thingItemResponse = ThingsItemResponse()
                thingItemResponse.id = id
                thingItemResponse.name = item.info?.name
                
                DispatchQueue.main.async {
                    self?.output?.getAlbum(albumItem: AlbumItem(remote: albumResponse),
                                           forItem: ThingsItem(response: thingItemResponse))
                }
            }, fail:  { fail in
                DispatchQueue.main.async {
                    self.output?.failedGetAlbum()
                }
            })
        }
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
