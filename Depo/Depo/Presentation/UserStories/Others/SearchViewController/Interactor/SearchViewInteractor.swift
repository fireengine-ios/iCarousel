//
//  SearchViewInteractor.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class SearchViewInteractor: SearchViewInteractorInput {
    
    weak var output: SearchViewInteractorOutput!
    
    var remoteItems: RemoteSearchService
    
    init(remoteItems: RemoteSearchService) {
        self.remoteItems = remoteItems
    }
    
    func viewIsReady() {
        
    }
    
    func searchItems(by searchText: String, sortBy: SortType, sortOrder: SortOrder) {
        remoteItems.allItems(searchText, sortBy: sortBy, sortOrder: sortOrder,
             success: { [weak self] (items) in
                self?.items(items: items)
                DispatchQueue.main.async {
                    self?.output.endSearchRequestWith(text: searchText)
                }
            }, fail: {
                DispatchQueue.main.async {
                    self.output.failedSearch()
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
                    wrapOutput.successWithSuggestList(list: suggestList)
                }
            }
        }, fail: { (_) in
        })
    }
}
