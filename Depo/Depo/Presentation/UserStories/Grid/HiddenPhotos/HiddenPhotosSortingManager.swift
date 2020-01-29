//
//  HiddenPhotosSortingManager.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol HiddenPhotosSortingManagerDelegate: class {
    func sortingRuleChanged(rule: SortedRules)
}

final class HiddenPhotosSortingManager {
    
    private lazy var topBar = GridListTopBar.initFromXib()
        
    private lazy var gridListTopBarConfig = GridListTopBarConfig(
        defaultGridListViewtype: .Grid,
        availableSortTypes: sortTypes,
        defaultSortType: .TimeNewOld,
        availableFilter: false,
        showGridListButton: false
    )
    
    private weak var delegate: HiddenPhotosSortingManagerDelegate?
    private let sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
    
    var isActive = true {
        didSet {
            topBar.view.isHidden = !isActive
        }
    }
    
    required init(delegate: HiddenPhotosSortingManagerDelegate?) {
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

extension HiddenPhotosSortingManager: GridListTopBarDelegate {
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) { }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        delegate?.sortingRuleChanged(rule: rule.sortedRulesConveted)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) { }
}
