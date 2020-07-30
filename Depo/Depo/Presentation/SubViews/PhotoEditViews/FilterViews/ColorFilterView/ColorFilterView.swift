//
//  ColorFilterView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ColorFilterView: UIView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: FilterSliderViewDelegate?) -> ColorFilterView {
        let view = ColorFilterView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var hlsButton: UIButton!
    @IBOutlet private weak var contentView: UIStackView!
    
    private weak var delegate: FilterSliderViewDelegate?
    
    private func setup(parameters: [AdjustmentParameterProtocol], delegate: FilterSliderViewDelegate?) {
        backgroundColor = ColorConstants.filterBackColor
        
        self.delegate = delegate
        
        parameters.forEach {
            let view = FilterSliderView.with(parameter: $0, delegate: delegate)
            contentView.addArrangedSubview(view)
        }
    }

    @IBAction private func onHLSTapped(_ sender: UIButton) {
        delegate?.leftButtonTapped()
    }
}
