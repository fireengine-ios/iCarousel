//
//  AdjustFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AdjustFilterView: AdjustmentsView, NibInit {

    static func with(parameter: AdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) -> AdjustFilterView {
        let view = AdjustFilterView.initFromNib()
        view.setup(with: parameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var sliderView: AdjustmentParameterSliderView!
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
    
    func setup(with parameter: AdjustmentParameterProtocol, delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: [parameter], delegate: delegate)
        
        sliderView.setup(with: parameter, delegate: self)
        minValueLabel.text = "\(Int(parameter.minValue))"
        maxValueLabel.text = "\(Int(parameter.maxValue))"
        currentValueLabel.text = String(format: "%.1f", parameter.currentValue)
    }
    
    //MARK: - Actions
    
    @IBAction private func onLeftButtonTapped(_ sender: UIButton) {
        delegate?.showAdjustMenu()
    }
    
    @IBAction private func onRightButtonTapped(_ sender: UIButton) {
        delegate?.roatate90Degrees()
    }
    
    override func sliderValueChanged(newValue: Float, type: AdjustmentParameterType) {
        super.sliderValueChanged(newValue: newValue, type: type)
        currentValueLabel.text = String(format: "%.1f", newValue)
    }
}
