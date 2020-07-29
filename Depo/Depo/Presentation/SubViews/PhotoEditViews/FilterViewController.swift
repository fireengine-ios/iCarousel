//
//  FilterViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

let filterBackColor = UIColor.darkGray

//Test controller
final class FilterViewController: ViewController, NibInit {

    @IBOutlet private weak var filtersScrollView: UIScrollView! {
        willSet {
            newValue.backgroundColor = filterBackColor
        }
    }

    @IBOutlet private weak var filtersContainerView: UIView! {
        willSet {
            newValue.backgroundColor = filterBackColor
        }
    }
    
    @IBOutlet private weak var bottomBarContainer: UIView!
    
    private var currentFilterViewType = FilterViewType.light
    private lazy var tabbar: PhotoEditTabbar = {
        let tabbar = PhotoEditTabbar.initFromNib()
        tabbar.setup(with: [.filters, .adjustments])
        tabbar.delegate = self
        return tabbar
    }()
    
    private lazy var filterCategoriesView = FilterCategoriesView.with(delegate: self)
    private var changesFilterView: FilterChangesBar?
    
    private lazy var animator = ContentAnimator()
    private var manager: AdjustmentManager?
    private var sourceImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showInitialState()
    }
    
    private func showInitialState() {
        animator.showTransition(to: filterCategoriesView, on: filtersContainerView, animated: true)
        animator.showTransition(to: tabbar, on: bottomBarContainer, animated: true)
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
        //switch tab
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
