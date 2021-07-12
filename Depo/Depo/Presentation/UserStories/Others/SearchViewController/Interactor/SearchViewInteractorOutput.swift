//
//  SearchViewInteractorOutput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInteractorOutput: AnyObject {
    func endSearchRequestWith(text: String)
    func getContentWithSuccess(items: [Item])
    func successWithSuggestList(list: [SuggestionObject])
    func setRecentSearches(_ recentSearches: [SearchCategory: [SuggestionObject]])
    func failedSearch()
    func getAlbum(albumItem: AlbumItem, forItem item: Item)
    func failedGetAlbum()
}
