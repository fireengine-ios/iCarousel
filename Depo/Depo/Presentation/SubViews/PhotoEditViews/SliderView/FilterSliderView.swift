//
//  FilterSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FilterSliderViewDelegate: class {
    func leftButtonTapped()
    func rightButtonTapped()
    func sliderValueChanged(newValue: Float, type: AdjustmentParameterType)
}

final class FilterSliderView: AdjustmentParameterSliderView, NibInit {

    static func with(parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) -> FilterSliderView {
        let view = FilterSliderView.initFromNib()
        view.setup(with: parameter, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var labelsView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaDemFont(size: 12)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.textAlignment = .right
            newValue.font = .TurkcellSaturaDemFont(size: 12)
            newValue.textColor = .white
        }
    }

    override func setup(with parameter: AdjustmentParameterProtocol, delegate: FilterSliderViewDelegate?) {
        super.setup(with: parameter, delegate: delegate)
        
        titleLabel.text = parameter.type.rawValue.capitalized
        valueLabel.text = String(format: "%.1f", parameter.currentValue)
    }
    
    override func didChangeValue(_ value: CGFloat) {
        valueLabel.text = String(format: "%.1f", value)
    }

}
