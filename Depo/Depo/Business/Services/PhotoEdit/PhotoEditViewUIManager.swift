//
//  PhotoEditViewUIManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditViewUIManagerDelegate: class {
    func needShowAdjustmentView(for type: AdjustmentViewType)
}

final class PhotoEditViewUIManager: NSObject {
    
    @IBOutlet private weak var navBarContainer: UIView!
    @IBOutlet private weak var imageScrollView: ImageScrollView! 
    
    @IBOutlet private weak var filtersScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.filterBackColor
            newValue.showsVerticalScrollIndicator = false
        }
    }

    @IBOutlet private weak var filtersContainerView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.filterBackColor
        }
    }

    @IBOutlet private weak var bottomSafeAreaView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.filterBackColor
        }
    }
    
    @IBOutlet private weak var bottomBarContainer: UIView!
    
    private(set) lazy var tabbar: PhotoEditTabbar = {
        let tabbar = PhotoEditTabbar.initFromNib()
        tabbar.setup(with: [.filters, .adjustments])
        tabbar.delegate = self
        return tabbar
    }()
    
    private(set) lazy var navBarView = PhotoEditNavbar.initFromNib()
    
    private lazy var preferredFiltersView = PreparedFiltersView.with(filters: PreparedFilterCategory.tempArray, delegate: self)
    private lazy var adjustmentCategoriesView = AdjustmentCategoriesView.with(delegate: self)
    private var changesBar: PhotoEditChangesBar?
    
    private lazy var animator = ContentAnimator()
    private(set) var currentAdjustmentViewType = AdjustmentViewType.light
    
    weak var delegate: PhotoEditViewUIManagerDelegate?
    
    var image: UIImage? {
        get {
            imageScrollView.imageView.originalImage
        }
        set {
            DispatchQueue.toMain {
                self.imageScrollView.imageView.originalImage = newValue
            }
        }
    }
    
    //MARK: -
    
    func viewDidLayoutSubviews() {
        imageScrollView.updateZoom()
        imageScrollView.adjustFrameToCenter()
    }
    
    func showInitialState() {
        showTabBarItemView(tabbar.selectedType)
        animator.showTransition(to: navBarView, on: navBarContainer, animated: true)
        animator.showTransition(to: tabbar, on: bottomBarContainer, animated: true)
    }
    
    private func showTabBarItemView(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            animator.showTransition(to: preferredFiltersView, on: filtersContainerView, animated: true)
        case .adjustments:
            animator.showTransition(to: adjustmentCategoriesView, on: filtersContainerView, animated: true)
        }
    }
}

//MARK: - PhotoEditTabbarDelegate

extension PhotoEditViewUIManager: PhotoEditTabbarDelegate {
    func didSelectItem(_ item: PhotoEditTabbarItemType) {
        showTabBarItemView(item)
    }
}

//MARK: - FilterCategoriesViewDelegate

extension PhotoEditViewUIManager: AdjustmentCategoriesViewDelegate {
    func didSelectCategory(_ category: AdjustmentCategory) {
        let viewType: AdjustmentViewType
        
        switch category {
        case .adjust:
            viewType = .adjust
        case .color:
            viewType = .color
        case .effect:
            viewType = .effect
        case .light:
            viewType = .light
        }
        
        delegate?.needShowAdjustmentView(for: viewType)
    }
    
    func showFilter(type: AdjustmentViewType, view: UIView, changesBar: PhotoEditChangesBar) {
        currentAdjustmentViewType = type
        animator.showTransition(to: view, on: filtersContainerView, animated: true)
        animator.showTransition(to: changesBar, on: bottomBarContainer, animated: true)
        navBarView.state = .initial
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewUIManager: PreparedFiltersViewDelegate {
    func didSelectPreparedFilter(_ filter: PreparedFilter) {
//        delegate?.needShowFilterView(for: .preparedFilter)
    }
}

//MARK: - ContentAnimator

private final class ContentAnimator {
    
    func showTransition(to newView: UIView, on contentView: UIView, animated: Bool) {
        let currentView = contentView.subviews.first
        
        guard newView != currentView else {
            return
        }
        
        DispatchQueue.main.async {
            let updateContentConstaints: VoidHandler = {
                newView.translatesAutoresizingMaskIntoConstraints = false
                newView.pinToSuperviewEdges()
                contentView.layoutIfNeeded()
            }
            
            newView.frame.size.width = contentView.frame.width
            contentView.frame.size.height = newView.frame.height
            contentView.frame.origin.y += newView.frame.origin.y - contentView.frame.origin.y
            
            if let oldView = currentView {
                let duration = animated ? 0.25 : 0.0
                UIView.transition(from: oldView, to: newView, duration: duration, options: [.curveLinear], completion: { _ in
                    updateContentConstaints()
                })
            } else {
                contentView.addSubview(newView)
                updateContentConstaints()
            }
        }
    }
}
