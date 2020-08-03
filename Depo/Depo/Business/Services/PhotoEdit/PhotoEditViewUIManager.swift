//
//  PhotoEditViewUIManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditViewUIManagerDelegate: class {
    func needShowFilterView(for type: FilterViewType)
}

final class PhotoEditViewUIManager: NSObject {
    
    @IBOutlet private weak var contentImageVIew: UIView! {
        willSet {
            newValue.backgroundColor = .black
        }
    }
    
    @IBOutlet private weak var navBarContainer: UIView!
    @IBOutlet private weak var imageScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = .black
            newValue.minimumZoomScale = 1
            newValue.maximumZoomScale = 5
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var filtersScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = ColorConstants.filterBackColor
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
    private lazy var filterCategoriesView = FilterCategoriesView.with(delegate: self)
    private var changesFilterView: FilterChangesBar?
    
    private lazy var animator = ContentAnimator()
    private(set) var currentFilterViewType = FilterViewType.light
    
    weak var delegate: PhotoEditViewUIManagerDelegate?
    
    //MARK: -
    
    func showInitialState() {
        showTabBarItemView(tabbar.selectedType)
        animator.showTransition(to: navBarView, on: navBarContainer, animated: true)
        animator.showTransition(to: tabbar, on: bottomBarContainer, animated: true)
        navBarView.state = .initial
    }
    
    func setImage(_ image: UIImage?) {
        DispatchQueue.toMain {
            self.imageView.image = image
        }
    }
    
    private func showTabBarItemView(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            animator.showTransition(to: preferredFiltersView, on: filtersContainerView, animated: true)
        case .adjustments:
            animator.showTransition(to: filterCategoriesView, on: filtersContainerView, animated: true)
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

extension PhotoEditViewUIManager: FilterCategoriesViewDelegate {
    func didSelectCategory(_ category: FilterCategory) {
        let viewType: FilterViewType
        
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
        
        delegate?.needShowFilterView(for: viewType)
    }
    
    func showFilter(type: FilterViewType, view: UIView, changesBar: FilterChangesBar) {
        currentFilterViewType = type
        animator.showTransition(to: view, on: filtersContainerView, animated: true)
        animator.showTransition(to: changesBar, on: bottomBarContainer, animated: true)
        navBarView.state = .edit
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewUIManager: PreparedFiltersViewDelegate {
    func didSelectPreparedFilter(_ filter: PreparedFilter) {
        
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

