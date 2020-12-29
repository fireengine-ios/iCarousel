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
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    private let accountService = AccountService()
    
    init(remoteItems: RemoteSearchService, recentSearches: RecentSearchesService) {
        self.remoteItems = remoteItems
        self.recentSearches = recentSearches
    }
    
    func viewIsReady() {
        self.faceImageAllowed { [weak self] result in
            guard let `self` = self else { return }

            if result {
                self.output?.setRecentSearches(self.recentSearches.searches)
            } else {
                var searches = [SearchCategory: [SuggestionObject]]()
            
                self.recentSearches.searches.forEach({ key, list in
                    if key != .people && key != .things {
                        searches[key] = list
                    }
                })
                self.output?.setRecentSearches(searches)
            }
        }
    }
    
    func searchItems(by searchText: String, item: SuggestionObject?, sortBy: SortType, sortOrder: SortOrder) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .search, eventLabel: .search(searchText))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Search())
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
             success: { [weak self] items in
                guard let `self` = self else { return }
                self.items(items: items)
                DispatchQueue.main.async {
                    if let searchItem = item {
                        self.recentSearches.addSearch(item: searchItem)
                    } else {
                        self.recentSearches.addSearch(searchText)
                    }
                    
                    self.faceImageAllowed { [weak self] result in
                        guard let `self` = self else { return }
                        if result {
                            self.output?.setRecentSearches(self.recentSearches.searches)
                        } else {
                            var searches = [SearchCategory: [SuggestionObject]]()
                            
                            self.recentSearches.searches.forEach({ key, list in
                                if key != .people && key != .things {
                                    searches[key] = list
                                }
                            })
                            self.output?.setRecentSearches(searches)
                        }
                    }
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
    
    private func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        accountService.getSettingsInfoPermissions(handler: { response in
            switch response {
            case .success(let result):
                guard let allowed = result.isFaceImageAllowed else {
                    completion(false)
                    return
                }
                
                completion(allowed)
            case .failed(_):
                completion(false)
            }
        })
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder ) {
        remoteItems.nextItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
                              success: { [weak self] items in
                                self?.items(items: items)
            }, fail: { })
    }
    
    func allItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder) {
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            self?.items(items: items)
            }, fail: { })
    }
    
    func needShowNoFileView() -> Bool {
        return true
    }
    
    private func filterSuggetion(items: [SuggestionObject]?, faceImageAllowed: Bool) -> [SuggestionObject] {
        var result = [SuggestionObject]()
        guard let items = items else {
            return result
        }
 
        if faceImageAllowed {
            result = items.filter { $0.text != nil }
            /// maybe will be need
            /*for suggest in items {
                var hasDuplicate = false
                
                if suggest.info?.id == nil, //simple suggestion
                    let type = suggest.type, let text = suggest.text,
                    items.first(where: { $0.type == type && $0.text == text && $0.info?.id != nil }) != nil {
                    hasDuplicate = true
                }
                
                if !hasDuplicate && suggest.text != nil {
                    result.append(suggest)
                }
            }*/
        } else {
            result = items.filter { $0.text != nil && $0.type != .people && $0.type != .thing }
        }
        
        return result
    }
    
    func clearRecentSearches() {
        recentSearches.clearAll()
        output?.setRecentSearches(recentSearches.searches)
    }
    
    func saveSearch(item: SuggestionObject) {
        recentSearches.addSearch(item: item)
        output?.setRecentSearches(recentSearches.searches)
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SearchScreen())
        analyticsManager.logScreen(screen: .search)
        analyticsManager.trackDimentionsEveryClickGA(screen: .search)
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
