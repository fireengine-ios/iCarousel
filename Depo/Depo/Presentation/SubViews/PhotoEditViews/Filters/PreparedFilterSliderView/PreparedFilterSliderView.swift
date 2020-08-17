//
//  PreparedFilterSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PreparedFilterSliderViewDelegate: class {
    func didChangeFilterIntensity(_ newValue: Float, filterType: PhotoFilterType)
}

enum PhotoFilterType {
    case filter1
}

final class PreparedFilterSliderView: UIView, NibInit {

    static func with(filterType: PhotoFilterType, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        let view = PreparedFilterSliderView.initFromNib()
        view.setup(filterType: filterType, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    private let slider = SliderView()
    
    private weak var delegate: PreparedFilterSliderViewDelegate?
    
    private var filterType: PhotoFilterType?
    
    private func setup(filterType: PhotoFilterType, delegate: PreparedFilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.filterBackColor
        self.filterType = filterType
        self.delegate = delegate

        setupSlider(filterType: filterType)
    }

    private func setupSlider(filterType: PhotoFilterType) {
        if slider.superview == nil {
            sliderContentView.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.pinToSuperviewEdges()
        }
        
//        slider.setup(minValue: parameter.minValue,
//                     maxValue: parameter.maxValue,
//                     anchorValue: parameter.defaultValue,
//                     currentValue: parameter.currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.delegate?.didChangeFilterIntensity(value, filterType: filterType)
        }
    }


}

