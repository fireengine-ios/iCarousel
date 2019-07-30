//
//  SpotifyPlaylistsSortingManager.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyPlaylistsSortingManagerDelegate: class {
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType)
}

final class SpotifyPlaylistsSortingManager {
    
    private lazy var topBar = GridListTopBar.initFromXib()
    
    private let gridListTopBarConfig = GridListTopBarConfig(
        defaultGridListViewtype: .Grid,
        availableSortTypes: [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest],
        defaultSortType: .TimeNewOld,
        availableFilter: false,
        showGridListButton: false
    )
    
    private weak var delegate: SpotifyPlaylistsSortingManagerDelegate?
    
    required init(delegate: SpotifyPlaylistsSortingManagerDelegate? = nil) {
        self.delegate = delegate
    }
    
    func addBarView(to superview: UIView) {
        guard let barView = topBar.view else {
            return
        }
        barView.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(barView)
        barView.pinToSuperviewEdges()
        
        topBar.delegate = self
        topBar.setupWithConfig(config: gridListTopBarConfig)
    }
}

extension SpotifyPlaylistsSortingManager: GridListTopBarDelegate {
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) { }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        delegate?.sortingRuleChanged(rule: rule)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) { }
}
