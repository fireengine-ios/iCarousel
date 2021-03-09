//
//  ComposedTopBarManager.swift
//  Depo
//
//  Created by Alex Developer on 03.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

enum TopBarOptions {
    case title
    case search
    case sorting
    //case segment
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
    
    var title = ""
    
    weak var delegate: ComposedTopBarManagerDelegate?
    
    private var options = [TopBarOptions]()
    
    let topBar = ComposedTopBar.initFromNib()
    
    private(set) var titleSubView: TopBarTitleView?
    private var sortingSubView: TopBarSortingView?
    private var searchSubView: TopBarSearchView?
    
    //should I keep search bar separate and call it from here? or should controller hold it?
    
    
    //delegate: ComposedTopBarManagerDelegate,
    init(topBarOptions: [TopBarOptions] = [. search, .title, .sorting]) {
//        self.delegate = delegate
        options = topBarOptions
    }
    
    
    func getTopBarView(with topBarOptions: [TopBarOptions] = [],
                       sortTypes: [MoreActionsConfig.SortRullesType] = [],
                       defaultSortType: MoreActionsConfig.SortRullesType,
                       titlteText: String) -> UIView {
        if !topBarOptions.isEmpty {
            options = topBarOptions
        }
        if !sortTypes.isEmpty {
            sortRules = sortTypes
        }
        title = titlteText
        self.defaultSortType = defaultSortType
//        currentTopBarStackSubViews.removeAll()
        composeTopBar()
        
        return topBar
    }
    
    func adaptOffset(offset: CGFloat) {
        guard let titleSubView = titleSubView else {
            return
        }
        
        let relativeFrame = topBar.convert(titleSubView.frame, to: topBar.superview)
        
        let relativeTitleViewTopY = relativeFrame.origin.y
        let relativeTitleViewBotY = relativeTitleViewTopY + titleSubView.frame.height
        
        let specialOffsett = offset - relativeTitleViewBotY
        
        if (relativeTitleViewTopY...relativeTitleViewBotY).contains(offset) {
            let alpha: CGFloat = -specialOffsett/titleSubView.frame.height
            titleSubView.titleLabel.alpha = alpha
        } else {
            titleSubView.titleLabel.alpha = offset > relativeTitleViewBotY ? 0 : 1
        }
    }
    
    private func composeTopBar() {
        
        options.forEach { type in
            
            let newSubView: UIView
            
            switch type {
            case .title:
                let titleView = TopBarTitleView.initFromNib()
                titleView.setup(text: title)
                titleSubView = titleView
                newSubView = titleView
            case .sorting:
                let sortingView = TopBarSortingView.initFromNib()
                sortingView.delegate = self
                sortingView.setupSortingMenu(sortTypes: sortRules, defaultSortType: defaultSortType)
                sortingSubView = sortingView
                newSubView = sortingView
            case .search:
                let searchView = TopBarSearchView.initFromNib()
                
                searchSubView = searchView
                newSubView = searchView
            }
            
            self.topBar.stackView.addArrangedSubview(newSubView)
        }
    }
    
}

extension ComposedTopBarManager: TopBarSortingViewDelegate {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType) {
        delegate?.sortingTypeChanged(sortType: sortType)
    }
}
