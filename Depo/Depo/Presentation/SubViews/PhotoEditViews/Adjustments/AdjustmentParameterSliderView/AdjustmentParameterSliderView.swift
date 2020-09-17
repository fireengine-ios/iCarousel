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
            newValue.font = Device.isIpad ? .TurkcellSaturaRegFont(size: 16) : .TurkcellSaturaMedFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textAlignment = .right
            newValue.font = Device.isIpad ? .TurkcellSaturaRegFont(size: 16) : .TurkcellSaturaMedFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView! {
        willSet {
            newValue.spacing = Device.isIpad ? 8 : 1
        }
    }
    @IBOutlet private weak var sliderContentView: UIView!
    
    private let slider = SliderView()
    
    private(set) weak var delegate: AdjustmentParameterSliderViewDelegate?
    private(set) var type: AdjustmentParameterType?
    
    private var isAvailableToReadTouch = false
    
    //MARK: - Setup

    func setup(with parameter: AdjustmentParameterProtocol, delegate: AdjustmentParameterSliderViewDelegate?) {
        self.type = parameter.type
        self.delegate = delegate
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        titleLabel.text = parameter.type.title
        valueLabel.text = String(format: "%.1f", parameter.currentValue)
        
        setupSlider(parameter: parameter)
    }
    
    func setupGradient(startColor: UIColor, endColor: UIColor) {
        slider.setupGradient(startColor: startColor, endColor: endColor)
    }
    
    func updateGradient(startColor: UIColor, endColor: UIColor) {
        slider.updateGradient(startColor: startColor, endColor: endColor)
    }
    
    func resetToDefaultValue() {
        let defaultValue = slider.slider.filledTrackAnchorValue
        valueLabel.text = String(format: "%.1f", defaultValue)
        slider.slider.value = defaultValue
    }
    
    private func setupSlider(parameter: AdjustmentParameterProtocol) {
        slider.add(to: sliderContentView)
        
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

extension AdjustmentParameterSliderView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            guard let sliderThumb = slider.getThumbView() else {
                return
            }
            
            let relativeThumbFrame = convert(sliderThumb.frame, from: slider)
            
            let enlargedTouchFrame = CGRect(x: relativeThumbFrame.minX - 20, y: relativeThumbFrame.minY - 20, width: relativeThumbFrame.maxX + 20, height: relativeThumbFrame.maxY + 20)
            if enlargedTouchFrame.contains(currentPoint) {
                isAvailableToReadTouch = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailableToReadTouch else {
            return
        }
        
        let onePercentSlider = slider.frame.maxX / 100
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            if currentPoint.x <= slider.frame.minX {
                slider.slider.setValue(0, animated: true)
            } else if currentPoint.x >= slider.frame.maxX {
                slider.slider.setValue(1.0, animated: true)
            } else {
                let percentageValue = currentPoint.x / onePercentSlider / 100
                slider.slider.setValue(percentageValue, animated: false)
                valueLabel.text = String(format: "%.1f", percentageValue)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAvailableToReadTouch {
            isAvailableToReadTouch = false
        }
    }
}
