//
//  TrashBinSortingManager.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinSortingManagerDelegate: class {
    func sortingRuleChanged(rule: SortedRules)
    func viewTypeChanged(viewType: MoreActionsConfig.ViewType)
}

final class TrashBinSortingManager {
    
    private lazy var topBar = GridListTopBar.initFromXib()
        
    private lazy var gridListTopBarConfig = GridListTopBarConfig(
        defaultGridListViewtype: .List,
        availableSortTypes: sortTypes,
        defaultSortType: .TimeNewOld,
        availableFilter: false,
        showGridListButton: true
    )
    
    private weak var delegate: TrashBinSortingManagerDelegate?
    private let sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    
    required init(delegate: TrashBinSortingManagerDelegate?) {
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

extension TrashBinSortingManager: GridListTopBarDelegate {
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) { }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        delegate?.sortingRuleChanged(rule: rule.sortedRulesConveted)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) {
        delegate?.viewTypeChanged(viewType: viewType)
    }
}
