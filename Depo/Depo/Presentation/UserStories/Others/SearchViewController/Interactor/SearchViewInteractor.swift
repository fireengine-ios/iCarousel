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
    
    init(remoteItems: RemoteSearchService, recentSearches: RecentSearchesService) {
        self.remoteItems = remoteItems
        self.recentSearches = recentSearches
    }
    
    func viewIsReady() {
        output?.setRecentSearches(recentSearches.searches)
        getDefaultSuggetion(text: "")
    }
    
    func searchItems(by searchText: String, type: SuggestionType?, sortBy: SortType, sortOrder: SortOrder) {
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
             success: { [weak self] (items) in
                guard let `self` = self else { return }
                self.items(items: items)
                DispatchQueue.main.async {
                    self.recentSearches.addSearch(searchText, type: type)
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
