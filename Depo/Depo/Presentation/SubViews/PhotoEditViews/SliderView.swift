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
        slider.setTrackFillColor(.lrTealishTwo, for: .normal)
        slider.setTrackBackgroundColor(ColorConstants.photoEditSliderColor, for: .normal)
        slider.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(didChangeSliderValue(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var gradientView = GradientView()
    
    private var previosValue = CGFloat.greatestFiniteMagnitude
    
    var changeValueHandler: ValueHandler<Float>?
    
    func getThumbView() -> UIView? {
        return slider.subviews.first?.subviews.first as? MDCThumbView
    }
    
    func add(to view: UIView) {
        guard superview == nil else {
            return
        }
        
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        pinToSuperviewEdges(offset: UIEdgeInsets(topBottom: 0, rightLeft: 4))
    }
    
    func setup(minValue: Float, maxValue: Float, anchorValue: Float, currentValue: Float) {
        backgroundColor = ColorConstants.photoEditBackgroundColor
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.pinToSuperviewEdges()
        
        slider.minimumValue = CGFloat(minValue)
        slider.maximumValue = CGFloat(maxValue)
        slider.filledTrackAnchorValue = CGFloat(anchorValue)
        slider.setValue(CGFloat(currentValue), animated: false)
    }
    
    func setupGradient(startColor: UIColor, endColor: UIColor) {
        guard gradientView.superview == nil else {
            updateGradient(startColor: startColor, endColor: endColor)
            return
        }
        
        gradientView.setup(withFrame: bounds,
                           startColor: startColor,
                           endColoer: endColor,
                           startPoint: .zero,
                           endPoint: CGPoint(x: 1, y: 0))
        
        addSubview(gradientView)
        sendSubview(toBack: gradientView)
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.heightAnchor.constraint(equalToConstant: 2).activate()
        gradientView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).activate()
        gradientView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).activate()
        gradientView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        gradientView.layoutSubviews()
        
        slider.setTrackBackgroundColor(.clear, for: .normal)
        slider.setTrackFillColor(.clear, for: .normal)
    }
    
    func updateGradient(startColor: UIColor, endColor: UIColor) {
        gradientView.gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
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
