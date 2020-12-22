//
//  SpotifySortingManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.

import Foundation

protocol SpotifySortingManagerDelegate: class {
    func sortingRuleChanged(rule: SortedRules)
}

final class SpotifySortingManager {
    
    private lazy var topBar = GridListTopBar.initFromXib()
    
    private lazy var gridListTopBarConfig = GridListTopBarConfig(
        defaultGridListViewtype: .Grid,
        availableSortTypes: sortTypes,
        defaultSortType: .TimeNewOld,
        availableFilter: false,
        showGridListButton: false
    )
    
    private weak var delegate: SpotifySortingManagerDelegate?
    private let sortTypes: [MoreActionsConfig.SortRullesType]
    
    required init(sortTypes: [MoreActionsConfig.SortRullesType], delegate: SpotifySortingManagerDelegate? = nil) {
        self.sortTypes = sortTypes
        self.delegate = delegate
    }
    
    func addBarView(to superview: UIView) {
        guard let barView = topBar.view else {
            assertionFailure("empty bar")
            return
        }
        barView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(barView)
        barView.pinToSuperviewEdges()
        barView.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        topBar.delegate = self
        topBar.setupWithConfig(config: gridListTopBarConfig)
    }
}

extension SpotifySortingManager: GridListTopBarDelegate {
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) { }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        delegate?.sortingRuleChanged(rule: rule.sortedRulesConveted)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) { }
}
