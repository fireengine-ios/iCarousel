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

    func searchWith(searchText: String, sortBy: SortType, sortOrder: SortOrder)
    func viewIsReady(collectionView: UICollectionView)
    func isShowedSpinner() -> Bool
    func getSuggestion(text: String)
    func tapCancel()
    
    func viewAppearanceChangedTopBar(asGrid: Bool)
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType)
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType])
    
    func playerDidHide()
    func willDismissController()
}
