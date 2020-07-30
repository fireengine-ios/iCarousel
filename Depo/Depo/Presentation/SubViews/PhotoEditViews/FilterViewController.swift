//
//  FilterViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

//Test controller
final class FilterViewController: ViewController, NibInit {

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
    
    @IBOutlet private weak var navBarContainer: UIView! {
        willSet {
            newValue.addSubview(navBarView)
            navBarView.translatesAutoresizingMaskIntoConstraints = false
            navBarView.pinToSuperviewEdges()
        }
    }
    @IBOutlet private weak var bottomBarContainer: UIView!
    
    private var currentFilterViewType = FilterViewType.light
    
    private lazy var navBarView = PhotoEditNavbar.with(delegate: self)
    private lazy var tabbar: PhotoEditTabbar = {
        let tabbar = PhotoEditTabbar.initFromNib()
        tabbar.setup(with: [.filters, .adjustments])
        tabbar.delegate = self
        return tabbar
    }()
    
    private lazy var preferredFiltersView = PreparedFiltersView.with(filters: PreparedFilterCategory.tempArray, delegate: self)
    private lazy var filterCategoriesView = FilterCategoriesView.with(delegate: self)
    private var changesFilterView: FilterChangesBar?
    
    private lazy var animator = ContentAnimator()
    private var manager: AdjustmentManager?
    private var sourceImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        showInitialState()
    }
    
    private func showInitialState() {
        switch tabbar.selectedType {
        case .filters:
            animator.showTransition(to: preferredFiltersView, on: filtersContainerView, animated: true)
        case .adjustments:
            animator.showTransition(to: filterCategoriesView, on: filtersContainerView, animated: true)
        }
        
        animator.showTransition(to: tabbar, on: bottomBarContainer, animated: true)
        navBarView.state = .initial
    }
    
    private func showFilter(_ newType: FilterViewType) {
        manager = adjustmentManager(for: newType)
        guard let parameters = manager?.parameters, !parameters.isEmpty,
            let view = PhotoFilterViewFactory.generateView(for: newType,
                                                           adjustmentParameters: parameters,
                                                           delegate: self)
        else {
            return
        }
        currentFilterViewType = newType
        animator.showTransition(to: view, on: filtersContainerView, animated: true)
        
        let changesBar = PhotoFilterViewFactory.generateChangesBar(for: newType, delegate: self)
        animator.showTransition(to: changesBar, on: bottomBarContainer, animated: true)
        
        navBarView.state = .edit
    }

    private func adjustmentManager(for type: FilterViewType) -> AdjustmentManager? {
        let types: [AdjustmentType]
        
        switch type {
        case .adjust:
            //temp
            types = [.brightness]
        case .color:
            types = [.whiteBalance, .saturation, .gamma]
        case .effect:
            return nil
        case .hls:
            types = [.hue, .monochrome]
        case .light:
            types = [.brightness, .contrast, .exposure, .highlightsAndShadows]
        }

        return AdjustmentManager(types: types)
    }
    
    private func showSaveMenu() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAsCopyAction = UIAlertAction(title: "Save as copy", style: .default, handler: nil)
        let resetAction = UIAlertAction(title: "Reset to original", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.view.tintColor = UIColor.black
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.permittedArrowDirections = .up
        
        let moreButtonRect = navBarView.moreButton.convert(navBarView.moreButton.bounds, to: view)
        let rect = CGRect(x: moreButtonRect.midX, y: moreButtonRect.minY - 10, width: 10, height: 50)
        actionSheet.popoverPresentationController?.sourceRect = rect
        
        actionSheet.addActions(saveAsCopyAction, resetAction, cancelAction)
        
        present(actionSheet, animated: true)
    }
}

extension FilterViewController: FilterSliderViewDelegate {
    
    func leftButtonTapped() {
        switch currentFilterViewType {
        case .adjust:
            //show action menu
            break
        case .color:
            showFilter(.hls)
            break
        default:
            break
        }
    }
    
    func rightButtonTapped() {
        if currentFilterViewType == .adjust {
            //rotate
        }
    }
    
    func sliderValueChanged(newValue: Float, type: AdjustmentParameterType) {
        guard let manager = manager else {
            return
        }
        
        manager.applyOnValueDidChange(parameterType: type, value: newValue, sourceImage: sourceImage) { _ in
            debugPrint("new adjustment apply")
        }
    }
}

extension FilterViewController: PhotoEditTabbarDelegate {
    func didSelectItem(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            animator.showTransition(to: preferredFiltersView, on: filtersContainerView, animated: true)
        case .adjustments:
            animator.showTransition(to: filterCategoriesView, on: filtersContainerView, animated: true)
        }
    }
}

extension FilterViewController: FilterCategoriesViewDelegate {
    func didSelectCategory(_ category: FilterCategory) {
        switch category {
        case .adjust:
            showFilter(.adjust)
        case .color:
            showFilter(.color)
        case .effect:
            showFilter(.effect)
        case .light:
            showFilter(.light)
        }
    }
}

extension FilterViewController: FilterChangesBarDelegate {
    func cancelFilter() {
        showInitialState()
    }
    
    func applyFilter() {
        
    }
}

extension FilterViewController: PhotoEditNavbarDelegate {
    func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func onSavePhoto() {
        showSaveMenu()
    }
    
    func onMoreActions() {}
    func onSharePhoto() {}
}

extension FilterViewController: PreparedFiltersViewDelegate {
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
            
            newView.frame = contentView.bounds
            
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
