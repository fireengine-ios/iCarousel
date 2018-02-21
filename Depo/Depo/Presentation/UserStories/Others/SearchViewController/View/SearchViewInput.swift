//
//  SearchViewInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInput: class {
    func endSearchRequestWith(text: String)
    func successWithSuggestList(list: [SuggestionObject])
    func setRecentSearches(_ recentSearches: [SearchCategory: [SuggestionObject]])
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool)
    func getCollectionViewWidth() -> CGFloat
    func scrollViewDidScroll(scrollView: UIScrollView)
    func setupUnderNavBarBar(withConfig config: GridListTopBarConfig)
    func dismissController()
    func showMusicBar()
    
    func onSetSelection(state: Bool)
    func selectedItemsCountChange(with count: Int)
    
    func setNavBarRigthItem(active isActive: Bool)
}
