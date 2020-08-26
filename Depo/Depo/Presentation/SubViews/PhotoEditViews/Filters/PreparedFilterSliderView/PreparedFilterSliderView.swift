//
//  PreparedFilterSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PreparedFilterSliderViewDelegate: class {
    func didChangeFilter(_ filterType: FilterType, newValue: Float)
}

final class PreparedFilterSliderView: UIView, NibInit {

    static func with(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        let view = PreparedFilterSliderView.initFromNib()
        view.setup(filter: filter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textAlignment = .right
            newValue.font = .TurkcellSaturaMedFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    private let slider = SliderView()
    
    private weak var delegate: PreparedFilterSliderViewDelegate?
    
    private var filter: CustomFilterProtocol?
    
    private func setup(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.photoEditBackgroundColor
        sliderContentView.backgroundColor = ColorConstants.photoEditBackgroundColor
        valueLabel.text = String(format: "%.1f", filter.parameter.currentValue)
        
        self.filter = filter
        self.delegate = delegate

        setupSlider(filter: filter)
    }

    private func setupSlider(filter: CustomFilterProtocol) {
        slider.add(to: sliderContentView)
        
        slider.setup(minValue: filter.parameter.minValue,
                     maxValue: filter.parameter.maxValue,
                     anchorValue: filter.parameter.defaultValue,
                     currentValue: filter.parameter.currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.valueLabel.text = String(format: "%.1f", value)
            if let type = self?.filter?.type {
                self?.delegate?.didChangeFilter(type, newValue: value)
            }
        }
    }
}

