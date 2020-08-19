//
//  SliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSlider

final class SliderView: UIView {

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
    
    private var previosValue = CGFloat.greatestFiniteMagnitude
    
    var changeValueHandler: ValueHandler<Float>?
    
    func setup(minValue: Float, maxValue: Float, anchorValue: Float, currentValue: Float) {
        backgroundColor = ColorConstants.filterBackColor
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.pinToSuperviewEdges()
        
        slider.minimumValue = CGFloat(minValue)
        slider.maximumValue = CGFloat(maxValue)
        slider.filledTrackAnchorValue = CGFloat(anchorValue)
        slider.setValue(CGFloat(currentValue), animated: false)
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
        changeValueHandler?(Float(value))
    }
}
