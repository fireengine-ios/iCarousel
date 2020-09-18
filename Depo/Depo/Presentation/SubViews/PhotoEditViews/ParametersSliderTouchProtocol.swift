//
//  ParametersSliderTouchProtocol.swift
//  Depo
//
//  Created by Alex Developer on 18.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

protocol ParametersSliderTouchProtocol: UIResponder {
    var isAvailableToReadTouch: Bool { get set }
    var mainFeedbackGenerator: UIImpactFeedbackGenerator { get }
    var sliderView: SliderView { get }
    var valueLabelView: UILabel? { get }
}

extension ParametersSliderTouchProtocol {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let self = self as? UIView else {
            return
        }
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            guard let sliderThumb = sliderView.getThumbView() else {
                return
            }
            
            let enlargedThumbFrame = CGRect(x: sliderThumb.frame.origin.x - 35, y: sliderThumb.frame.origin.y - 30, width: sliderThumb.frame.size.width + 35, height: sliderThumb.frame.size.height + 30)
            
            if enlargedThumbFrame.contains(currentPoint) {
                mainFeedbackGenerator.prepare()
                isAvailableToReadTouch = true
            }
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard
            isAvailableToReadTouch,
            let self = self as? UIView else {
                return
        }
        
        let onePercentSlider = sliderView.frame.size.width / 100
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            if currentPoint.x <= sliderView.slider.frame.origin.x {
                if sliderView.slider.value > 0 {
                    mainFeedbackGenerator.impactOccurred()
                } else {
                    return
                }
                valueLabelView?.text = String(format: "%.1f", 0)
                sliderView.slider.setValue(0, animated: true)
            } else if currentPoint.x >= sliderView.slider.frame.size.width {
                if sliderView.slider.value < 1 {
                    mainFeedbackGenerator.impactOccurred()
                } else {
                    return
                }
                sliderView.slider.setValue(1.0, animated: true)
                valueLabelView?.text = String(format: "%.1f", 1)
                mainFeedbackGenerator.impactOccurred()
            } else {
                let percentageValue = currentPoint.x / onePercentSlider / 100
                sliderView.slider.setValue(percentageValue, animated: false)
                valueLabelView?.text = String(format: "%.1f", percentageValue)
            }
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAvailableToReadTouch {
            isAvailableToReadTouch = false
        }
    }
}
