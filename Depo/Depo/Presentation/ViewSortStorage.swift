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
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    private(set) var favoritesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var favoritesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
}

extension ViewSortStorage: BaseFilesGreedModuleOutput {
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            self.allFilesViewType = type
            self.allFilesSortType = sortedType
        } else if fieldType == .favorite {
            self.favoritesViewType = type
            self.favoritesSortType = sortedType
        }
    }
}
