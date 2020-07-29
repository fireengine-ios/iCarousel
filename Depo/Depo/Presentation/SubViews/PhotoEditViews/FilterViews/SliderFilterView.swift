//
//  SliderFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSlider

class SliderFilterView: UIView {

    @IBOutlet private weak var sliderContentView: UIView!
    
    let slider: MDCSlider = {
        let slider = MDCSlider()
        slider.filledTrackAnchorValue = 0
        slider.isContinuous = true
        slider.isStatefulAPIEnabled = true
        slider.setThumbColor(.white, for: .normal)
        slider.setTrackFillColor(.white, for: .normal)
        slider.setTrackBackgroundColor(.gray, for: .normal)
        slider.addTarget(self, action: #selector(didChangeSliderValue(_:)), for: .valueChanged)
        return slider
    }()
    
    private(set) weak var delegate: FilterSliderViewDelegate?
    private(set) var type: AdjustmentParameterType?
    
    func setup(with parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) {
        backgroundColor = filterBackColor
        sliderContentView.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.pinToSuperviewEdges()
        
        slider.setValue(CGFloat(parameter.currentValue), animated: false)
        slider.minimumValue = CGFloat(parameter.minValue)
        slider.maximumValue = CGFloat(parameter.maxValue)
    
        self.delegate = delegate
        type = parameter.type
    }
    
    //MARK: - Actions
    
    @objc private func didChangeSliderValue(_ sender: MDCSlider) {
        debugPrint(sender.value)
            
        didChangeValue(sender.value)
        if let type = type {
            delegate?.sliderValueChanged(newValue: Float(sender.value), type: type)
        }
    }
    
    func didChangeValue(_ value: CGFloat) { }

}
