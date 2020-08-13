//
//  AdjustmentParameterSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSlider

class AdjustmentParameterSliderView: UIView {

    @IBOutlet private weak var sliderContentView: UIView!
    
    let slider: MDCSlider = {
        let slider = MDCSlider()
        slider.isContinuous = true
        slider.isStatefulAPIEnabled = true
        slider.isThumbHollowAtStart = false
        slider.setThumbColor(.white, for: .normal)
        slider.setTrackFillColor(.white, for: .normal)
        slider.setTrackBackgroundColor(.gray, for: .normal)
        slider.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(didChangeSliderValue(_:)), for: .valueChanged)
        return slider
    }()
    
    private(set) weak var delegate: FilterSliderViewDelegate?
    private(set) var type: AdjustmentParameterType?
    private var previosValue = CGFloat.greatestFiniteMagnitude
    
    func setup(with parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.filterBackColor
        sliderContentView.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.pinToSuperviewEdges()
        
        slider.minimumValue = CGFloat(parameter.minValue)
        slider.maximumValue = CGFloat(parameter.maxValue)
        slider.filledTrackAnchorValue = CGFloat(parameter.defaultValue)
        slider.setValue(CGFloat(parameter.currentValue), animated: false)
    
        self.delegate = delegate
        type = parameter.type
    }
    
    //MARK: - Actions
    
    @objc private func didTouchUpInside(_ sender: MDCSlider) {
        updateValue(sender.value)
    }
    
    @objc private func didChangeSliderValue(_ sender: MDCSlider) {
        updateValue(sender.value)
    }
    
    private func updateValue(_ value: CGFloat) {
        guard value != previosValue else {
            return
        }
        
        previosValue = value
        didChangeValue(value)
        if let type = type {
            delegate?.sliderValueChanged(newValue: Float(value), type: type)
        }
    }
    
    func didChangeValue(_ value: CGFloat) { }

}
