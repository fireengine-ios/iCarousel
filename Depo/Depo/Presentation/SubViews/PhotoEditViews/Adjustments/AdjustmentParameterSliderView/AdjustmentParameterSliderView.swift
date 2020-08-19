//
//  AdjustmentParameterSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol AdjustmentParameterSliderViewDelegate: class {
    func sliderValueChanged(newValue: Float, type: AdjustmentParameterType)
}

final class AdjustmentParameterSliderView: UIView, NibInit {

    static func with(parameter: AdjustmentParameterProtocol, delegate: AdjustmentParameterSliderViewDelegate?) -> AdjustmentParameterSliderView {
        let view = AdjustmentParameterSliderView.initFromNib()
        view.setup(with: parameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var labelsView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaDemFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textAlignment = .right
            newValue.font = .TurkcellSaturaDemFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    
    private let slider = SliderView()
    
    private(set) weak var delegate: AdjustmentParameterSliderViewDelegate?
    private(set) var type: AdjustmentParameterType?
    
    //MARK: - Setup

    func setup(with parameter: AdjustmentParameterProtocol, delegate: AdjustmentParameterSliderViewDelegate?) {
        self.type = parameter.type
        self.delegate = delegate
        
        backgroundColor = ColorConstants.filterBackColor
        titleLabel.text = parameter.type.rawValue.capitalized
        valueLabel.text = String(format: "%.1f", parameter.currentValue)
        
        setupSlider(parameter: parameter)
    }
    
    private func setupSlider(parameter: AdjustmentParameterProtocol) {
        if slider.superview == nil {
            sliderContentView.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.pinToSuperviewEdges()
        }
        
        slider.setup(minValue: parameter.minValue,
                     maxValue: parameter.maxValue,
                     anchorValue: parameter.defaultValue,
                     currentValue: parameter.currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.valueLabel.text = String(format: "%.1f", value)
            self?.delegate?.sliderValueChanged(newValue: value, type: parameter.type)
        }
    }
}
