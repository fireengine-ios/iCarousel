//
//  ComposedTopBarManager.swift
//  Depo
//
//  Created by Alex Developer on 03.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

enum TopBarOptions {
    case sorting
    case segmented
}

protocol ComposedTopBarManagerDelegate: class {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType)
}

extension ComposedTopBarManagerDelegate {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType) {}
}

final class ComposedTopBarManager {
    
    var sortRules: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    
    var defaultSortType: MoreActionsConfig.SortRullesType = .AlphaBetricAZ
    
    private var title = ""
    
    weak var delegate: ComposedTopBarManagerDelegate?
    
    private var options = [TopBarOptions]()
    
    private var sortingSubView: TopBarSortingView?
    
    init(topBarOptions: [TopBarOptions] = [.segmented, .sorting]) {
        options = topBarOptions
    }
    

    
}

extension ComposedTopBarManager: TopBarSortingViewDelegate {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType) {
        delegate?.sortingTypeChanged(sortType: sortType)
    }
}

//MARK: - SortingView

extension ComposedTopBarManager {
    
    func getSortingSubView(sortTypes: [MoreActionsConfig.SortRullesType] = [],
                    defaultSortType: MoreActionsConfig.SortRullesType) -> UIView {
        if !sortTypes.isEmpty {
            sortRules = sortTypes
        }
        self.defaultSortType = defaultSortType
        
        let sortingView = TopBarSortingView.initFromNib()
        sortingView.delegate = self
        sortingView.setupSortingMenu(sortTypes: sortRules, defaultSortType: defaultSortType)
        sortingSubView = sortingView
        return sortingView
    }
    
}
