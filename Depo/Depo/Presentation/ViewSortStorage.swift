//
//  ViewSortStorage.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/29/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class ViewSortStorage {
    static let shared = ViewSortStorage()
    
    private(set) var allFilesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.lastModifiedTimeNewOld
    
    private(set) var favoritesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var favoritesSortType = MoreActionsConfig.SortRullesType.lastModifiedTimeNewOld
    
    func resetToDefault() {
        allFilesViewType = .Grid
        allFilesSortType = .lastModifiedTimeNewOld
        favoritesViewType = .Grid
        favoritesSortType = .lastModifiedTimeNewOld
    }
}

extension ViewSortStorage: BaseFilesGreedModuleOutput {
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            allFilesViewType = type
            allFilesSortType = sortedType
        } else if fieldType == .favorite {
            favoritesViewType = type
            favoritesSortType = sortedType
        }
    }
}
