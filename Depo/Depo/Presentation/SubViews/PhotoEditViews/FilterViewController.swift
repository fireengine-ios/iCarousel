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

    @IBOutlet private weak var filtersContainerView: UIView! {
        willSet {
            newValue.backgroundColor = filterBackColor
        }
    }
    
    private var currentFilterViewType = FilterViewType.light
    
    private lazy var animator = ContentViewAnimator()
    private var manager: AdjustmentManager?
    private var sourceImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFilter(to: .color)
    }
    
    private func showFilter(to newType: FilterViewType) {
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
            showFilter(to: .hls)
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
