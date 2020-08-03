//
//  LightFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class LightFilterView: UIView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: FilterSliderViewDelegate?) -> LightFilterView {
        let view = LightFilterView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    
    private func setup(parameters: [AdjustmentParameterProtocol], delegate: FilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.forEach {
            let view = FilterSliderView.with(parameter: $0, delegate: delegate)
            contentView.addArrangedSubview(view)
        }
    }

}
