//
//  AdjustFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSlider

final class AdjustFilterView: SliderFilterView, NibInit {

    static func with(parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) -> AdjustFilterView {
        let view = AdjustFilterView.initFromNib()
        view.setup(with: parameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    @IBOutlet private weak var minValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaDemFont(size: 12)
        }
    }
    
    @IBOutlet private weak var maxValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaDemFont(size: 12)
        }
    }
    
    @IBOutlet private weak var currentValueLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaDemFont(size: 12)
        }
    }
    
    override func setup(with parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) {
        super.setup(with: parameter, delegate: delegate)
        
        minValueLabel.text = "\(Int(parameter.minValue))"
        maxValueLabel.text = "\(Int(parameter.maxValue))"
        currentValueLabel.text = String(format: "%.1f", parameter.currentValue)
    }
    
    //MARK: - Actions
    
    @IBAction private func onLeftButtonTapped(_ sender: UIButton) {
        delegate?.leftButtonTapped()
    }
    
    @IBAction private func onRightButtonTapped(_ sender: UIButton) {
        delegate?.rightButtonTapped()
    }
    
    override func didChangeValue(_ value: CGFloat) {
        currentValueLabel.text = String(format: "%.1f", value)
    }
}
