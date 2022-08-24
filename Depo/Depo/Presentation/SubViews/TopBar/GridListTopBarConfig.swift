//
//  GridListTopBarConfig.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct GridListTopBarConfig {
    
    let defaultGridListViewtype: MoreActionsConfig.ViewType
    let availableSortTypes: [MoreActionsConfig.SortRullesType]
    let defaultSortType: MoreActionsConfig.SortRullesType
    
    let availableFilter: Bool
    let showGridListButton: Bool
    let showMoreButton: Bool
    let defaultFilterState: MoreActionsConfig.MoreActionsFileType
    var middleText: String?
    
    init(defaultGridListViewtype: MoreActionsConfig.ViewType = .Grid,
         availableSortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest],
         defaultSortType: MoreActionsConfig.SortRullesType = .TimeNewOld,
        availableFilter: Bool = false,
        showGridListButton: Bool = true,
        showMoreButton: Bool = true,
        middleText: String? = nil,
        defaultFilterState: MoreActionsConfig.MoreActionsFileType = .Photo) {
        self.defaultGridListViewtype = defaultGridListViewtype
        self.availableSortTypes = availableSortTypes
        self.defaultSortType = defaultSortType
        self.availableFilter = availableFilter
        self.showGridListButton = showGridListButton
        self.showMoreButton = showMoreButton
        self.middleText = middleText
        self.defaultFilterState = defaultFilterState
    }
    
}
