//
//  ComposedTopBarManager.swift
//  Depo
//
//  Created by Alex Developer on 03.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

enum TopBarOptions {
    case title
//    case search
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
    
    private(set) var titleSubView: TopBarTitleView?
    private var sortingSubView: TopBarSortingView?
    private var searchSubView: TopBarSearchView?
    
    init(topBarOptions: [TopBarOptions] = [.title, .sorting]) {
        options = topBarOptions
    }
    

    
    
    func getTopBarHeight() -> CGFloat {
        return 0//we dont count height till scroll? or we do inset and then make an offset chanhge?
    }
    
    
    
    func adaptOffset(offset: CGFloat) {
        adaptTitleView(offsetY: offset)
    }
    
    private func composeTopBar() {
        
//        options.forEach { type in
//
//            let newSubView: UIView
//
//            switch type {
//            case .title:
//
//            case .sorting:
//
//            case .search:
//                let searchView = TopBarSearchView.initFromNib()
//
//                searchSubView = searchView
//                newSubView = searchView
//            }
//
//            self.topBar.stackView.addArrangedSubview(newSubView)
//        }
    }
    
}

extension ComposedTopBarManager: TopBarSortingViewDelegate {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType) {
        delegate?.sortingTypeChanged(sortType: sortType)
    }
}

//MARK: - TitleView
extension ComposedTopBarManager {
    
    func getTitleSubView(titlteText: String) -> UIView {
        let titleView = TopBarTitleView.initFromNib()
        titleView.setup(text: title)
        titleSubView = titleView
        return titleView
    }
    
    private func adaptTitleView(offsetY: CGFloat) {
        guard let titleSubView = titleSubView else {
            return
        }
        
        let relativeFrame = titleSubView.frame//topBar.convert(titleSubView.frame, to: topBar.superview)
        
        let relativeTitleViewTopY = relativeFrame.origin.y
        let relativeTitleViewBotY = relativeTitleViewTopY + titleSubView.frame.height
        
        let specialOffsett = offsetY - relativeTitleViewBotY
        
        if (relativeTitleViewTopY...relativeTitleViewBotY).contains(offsetY) {
            let alpha: CGFloat = -specialOffsett/titleSubView.frame.height
            titleSubView.titleLabel.alpha = alpha
        } else {
            titleSubView.titleLabel.alpha = offsetY > relativeTitleViewBotY ? 0 : 1
        }
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
