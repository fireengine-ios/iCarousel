//
//  SearchViewInteractorInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInteractorInput {
    
    var alerSheetMoreActionsConfig: AlertFilesActionsSheetInitialConfig? { get }
    var bottomBarConfig: EditingBarConfig? { get set }
    
    func viewIsReady()
    func searchItems(by searchText: String, item: SuggestionObject?, sortBy: SortType, sortOrder: SortOrder)
    func needShowNoFileView() -> Bool
    func getSuggetion(text: String)
    func getDefaultSuggetion(text: String)
    func clearRecentSearches()
    func openFaceImageForSuggest(item: SuggestionObject)
    func openFaceImageForSearch(item: BaseDataSourceItem?)
    func saveSearch(item: SuggestionObject)
}
