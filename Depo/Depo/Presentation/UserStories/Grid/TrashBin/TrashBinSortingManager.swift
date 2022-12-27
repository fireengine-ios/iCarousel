//
//  TrashBinSortingManager.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinSortingManagerDelegate: AnyObject {
    func sortingRuleChanged(rule: SortedRules)
    func viewTypeChanged(viewType: MoreActionsConfig.ViewType)
    func onMoreButton(sender: Any)
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType)
}

final class TrashBinSortingManager {
    
    private lazy var topBar = GridListTopBar.initFromXib()
        
    private lazy var gridListTopBarConfig = GridListTopBarConfig(
        defaultGridListViewtype: .Grid,
        availableSortTypes: sortTypes,
        defaultSortType: .TimeNewOld,
        availableFilter: false,
        showGridListButton: true
    )
    
    private weak var delegate: TrashBinSortingManagerDelegate?
    private let sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    
    var isActive = true {
        didSet {
            topBar.view.isHidden = !isActive
        }
    }
    
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
    func onMoreButton() {
        delegate?.onMoreButton(sender: self)
    }
    
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) {
        delegate?.filterChanged(filter: filter)
    }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        delegate?.sortingRuleChanged(rule: rule.sortedRulesConveted)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) {
        delegate?.viewTypeChanged(viewType: viewType)
    }
}
