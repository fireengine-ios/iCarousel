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
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .light)
    }()
    
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
            
            let convertedThumbFrame = convert(sliderThumb.frame, from: sliderContentView)
            
            let enlargedThumbFrame = CGRect(x: convertedThumbFrame.origin.x - 30, y: convertedThumbFrame.origin.y - 30, width: convertedThumbFrame.size.width + 60, height: convertedThumbFrame.size.height + 60)
        
            if enlargedThumbFrame.contains(currentPoint) {
                feedbackGenerator.prepare()
                isAvailableToReadTouch = true
                touchesMoved(touches, with: event)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailableToReadTouch else {
            return
        }
        
        let onePercentSlider = slider.frame.size.width / 100
        
        var newValue: CGFloat
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)

            if currentPoint.x <= slider.slider.frame.origin.x {
                if slider.slider.value > 0 {
                    feedbackGenerator.impactOccurred()
                } else {
                    return
                }
                newValue = 0
//                valueLabel.text = String(format: "%.1f", 0)
//                slider.slider.setValue(0, animated: true)
            } else if currentPoint.x >= slider.slider.frame.size.width {
                if slider.slider.value < 1 {
                    feedbackGenerator.impactOccurred()
                } else {
                    return
                }
                newValue = 1.0
//                slider.slider.setValue(1.0, animated: true)
//                valueLabel.text = String(format: "%.1f", 1)
                feedbackGenerator.impactOccurred()
            } else {
                newValue = currentPoint.x / onePercentSlider / 100
            }
            
            slider.slider.setValue(newValue, animated: false)
            valueLabel.text = String(format: "%.1f", newValue)
            if let type = type {
                delegate?.sliderValueChanged(newValue: Float(newValue), type: type)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAvailableToReadTouch {
            isAvailableToReadTouch = false
        }
    }
}
