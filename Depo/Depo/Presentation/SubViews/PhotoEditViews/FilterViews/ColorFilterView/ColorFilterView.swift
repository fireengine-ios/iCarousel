//
//  ColorFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ColorFilterView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> ColorFilterView {
        let view = ColorFilterView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var hlsButton: UIButton!
    @IBOutlet private weak var contentView: UIStackView!
    
    override func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.forEach {
            let view = FilterSliderView.with(parameter: $0, delegate: self)
            contentView.addArrangedSubview(view)
        }
    }

    @IBAction private func onHLSTapped(_ sender: UIButton) {
        delegate?.showHLSFilter()
    }
}
