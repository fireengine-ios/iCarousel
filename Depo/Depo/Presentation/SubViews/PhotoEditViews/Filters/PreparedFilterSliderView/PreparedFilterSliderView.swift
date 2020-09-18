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

final class PreparedFilterSliderView: UIView, NibInit {

    static func with(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        let view = PreparedFilterSliderView.initFromNib()
        view.setup(filter: filter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textAlignment = .right
            newValue.font = Device.isIpad ? .TurkcellSaturaRegFont(size: 16) : .TurkcellSaturaMedFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstaint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstaint: NSLayoutConstraint!
    @IBOutlet private weak var valueTrailingConstaint: NSLayoutConstraint!
    
    private let slider = SliderView()
    
    private weak var delegate: PreparedFilterSliderViewDelegate?
    
    private var filter: CustomFilterProtocol?
    
    private var isAvailableToReadTouch = false
    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .light)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topConstraint.constant = Device.isIpad ? 30 : 16
        bottomConstraint.constant = Device.isIpad ? 40 : 16
        leadingConstaint.constant = Device.isIpad ? 80 : 16
        trailingConstaint.constant = Device.isIpad ? 80 : 16
        valueTrailingConstaint.constant = Device.isIpad ? 80 : 16
    }
    
    private func setup(filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.photoEditBackgroundColor
        sliderContentView.backgroundColor = ColorConstants.photoEditBackgroundColor
        valueLabel.text = String(format: "%.1f", filter.parameter.currentValue)
        
        self.filter = filter
        self.delegate = delegate

        setupSlider(filter: filter)
    }

    private func setupSlider(filter: CustomFilterProtocol) {
        slider.add(to: sliderContentView)
        
        slider.setup(minValue: filter.parameter.minValue,
                     maxValue: filter.parameter.maxValue,
                     anchorValue: filter.parameter.defaultValue,
                     currentValue: filter.parameter.currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.valueLabel.text = String(format: "%.1f", value)
            if let type = self?.filter?.type {
                self?.delegate?.didChangeFilter(type, newValue: value)
            }
        }
    }
}

extension PreparedFilterSliderView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            guard let sliderThumb = slider.getThumbView() else {
                return
            }
            
            let enlargedThumbFrame = CGRect(x: sliderThumb.frame.origin.x - 20, y: sliderThumb.frame.origin.y - 20, width: sliderThumb.frame.size.width + 20, height: sliderThumb.frame.size.height + 20)
            
            if enlargedThumbFrame.contains(currentPoint) {
                feedbackGenerator.prepare()
                isAvailableToReadTouch = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAvailableToReadTouch else {
            return
        }
        
        let onePercentSlider = slider.frame.size.width / 100
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            if currentPoint.x <= slider.slider.frame.origin.x {
                if slider.slider.value > 0 {
                    feedbackGenerator.impactOccurred()
                } else {
                    return
                }
                valueLabel.text = String(format: "%.1f", 0)
                slider.slider.setValue(0, animated: true)
            } else if currentPoint.x >= slider.slider.frame.size.width {
                if slider.slider.value < 1 {
                    feedbackGenerator.impactOccurred()
                } else {
                    return
                }
                slider.slider.setValue(1.0, animated: true)
                valueLabel.text = String(format: "%.1f", 1)
                feedbackGenerator.impactOccurred()
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
