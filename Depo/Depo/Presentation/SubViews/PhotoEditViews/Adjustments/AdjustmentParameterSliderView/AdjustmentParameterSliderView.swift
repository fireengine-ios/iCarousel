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
    
    private var _isAvailableToReadTouch = false
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

//MARK: - ParametersSliderTouchProtocol
///Basicaly protocol that works as a workaround for a MDCSlider native behavior
extension AdjustmentParameterSliderView: ParametersSliderTouchProtocol {
    var isAvailableToReadTouch: Bool {
        get {
            return _isAvailableToReadTouch
        }
        set {
            _isAvailableToReadTouch = newValue
        }
    }
    
    var mainFeedbackGenerator: UIImpactFeedbackGenerator {
        return  feedbackGenerator
    }
    
    var sliderView: SliderView {
        return slider
    }
    
    var valueLabelView: UILabel? {
        return valueLabel
    }

}
