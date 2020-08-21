//
//  AdjustView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AdjustView: AdjustmentsView, NibInit {

    static func with(parameter: AdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) -> AdjustView {
        let view = AdjustView.initFromNib()
        view.setup(with: parameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderContentView: UIView!
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var minValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    @IBOutlet private weak var maxValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    @IBOutlet private weak var currentValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaMedFont(size: 12)
        }
    }
    
    private let slider = SliderView()
    
    //MARK: - Setup
    
    func setup(with parameter: AdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: [parameter], delegate: delegate)
        
        minValueLabel.text = "\(Int(parameter.minValue))"
        maxValueLabel.text = "\(Int(parameter.maxValue))"
        currentValueLabel.text = String(format: "%.1f", parameter.currentValue)
        
        setupSlider(parameter: parameter)
    }
    
    private func setupSlider(parameter: AdjustmentParameterProtocol) {
        if slider.superview == nil {
            sliderContentView.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.pinToSuperviewEdges(offset: UIEdgeInsets(topBottom: 0, rightLeft: 8))
        }
        
        slider.setup(minValue: parameter.minValue,
                     maxValue: parameter.maxValue,
                     anchorValue: parameter.defaultValue,
                     currentValue: parameter.currentValue)
        
        slider.changeValueHandler = { [weak self] value in
            self?.currentValueLabel.text = String(format: "%.1f", value)
            self?.sliderValueChanged(newValue: value, type: parameter.type)
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func onLeftButtonTapped(_ sender: UIButton) {
        delegate?.showAdjustMenu()
    }
    
    @IBAction private func onRightButtonTapped(_ sender: UIButton) {
        delegate?.roatate90Degrees()
    }
}
