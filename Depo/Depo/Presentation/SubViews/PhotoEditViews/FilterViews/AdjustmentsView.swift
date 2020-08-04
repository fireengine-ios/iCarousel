//
//  AdjustmentsView.swift
//  Depo
//
//  Created by Andrei Novikau on 8/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias AdjustmentValue = (type: AdjustmentParameterType, value: Float)

protocol AdjustmentsViewDelegate: class {
    func showAdjustMenu()
    func showHLSFilter()
    func didChangeAdjustments(_ adjustments: [AdjustmentValue])
}

class AdjustmentsView: UIView, FilterSliderViewDelegate{
    
    var adjustments = [AdjustmentValue]()
    
    weak var delegate: AdjustmentsViewDelegate?
    
    func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        adjustments = parameters.map { AdjustmentValue(type: $0.type, value: $0.currentValue) }
        self.delegate = delegate
    }
    
    func sliderValueChanged(newValue: Float, type: AdjustmentParameterType) {
        guard let index = adjustments.firstIndex(where: { $0.type == type}) else {
            return
        }
        
        adjustments[index] = AdjustmentValue(type: type, value: newValue)
        delegate?.didChangeAdjustments(adjustments)
    }
}
