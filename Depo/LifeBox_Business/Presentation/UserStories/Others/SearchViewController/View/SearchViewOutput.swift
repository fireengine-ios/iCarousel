//
//  SearchViewOutput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewOutput {
    var player: MediaPlayer { get }
    var tabBarActionHandler: TabBarActionHandler { get }
    
    func searchWith(searchText: String, item: SuggestionObject?, sortBy: SortType, sortOrder: SortOrder)
    func viewIsReady(collectionView: UICollectionView)
    func isShowedSpinner() -> Bool
    func getSuggestion(text: String)
    func tapCancel()
    func onClearRecentSearchesTapped()
    
    func viewAppearanceChangedTopBar(asGrid: Bool)
    func sortedPushedTopBar(with rule: MoreActionsConfig.SortRullesType)
    
    func playerDidHide()
    func willDismissController()
    func viewWillDisappear()
    
    func moreActionsPressed(sender: Any)
    
    func openFaceImageItems(category: SearchCategory)
    func openFaceImage(item: SuggestionObject)
}
