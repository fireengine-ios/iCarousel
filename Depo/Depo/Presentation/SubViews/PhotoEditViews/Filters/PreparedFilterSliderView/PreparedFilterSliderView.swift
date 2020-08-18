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

enum PhotoFilterType {
    case filter1
}

final class PreparedFilterSliderView: UIView, NibInit {

    static func with(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        let view = PreparedFilterSliderView.initFromNib()
        view.setup(filter: filter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    private let slider = SliderView()
    
    private weak var delegate: PreparedFilterSliderViewDelegate?
    
    private var filter: CustomFilterProtocol?
    
    private func setup(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.filterBackColor
        self.filter = filter
        self.delegate = delegate

        setupSlider(filter: filter)
    }

    private func setupSlider(filter: CustomFilterProtocol) {
        if slider.superview == nil {
            sliderContentView.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.pinToSuperviewEdges()
        }
        
        if let parameter = filter.parameters.first {
            slider.setup(minValue: parameter.minValue,
                         maxValue: parameter.maxValue,
                         anchorValue: parameter.defaultValue,
                         currentValue: parameter.currentValue)
        }

        slider.changeValueHandler = { [weak self] value in
            if let type = self?.filter?.type {
                self?.delegate?.didChangeFilter(type, newValue: value)
            }
        }
    }
}

