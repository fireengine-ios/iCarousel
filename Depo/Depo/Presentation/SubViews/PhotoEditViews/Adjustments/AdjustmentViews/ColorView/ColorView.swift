//
//  ColorView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ColorView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> ColorView {
        let view = ColorView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var hslButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.photoEditHSL, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 15)
        }
    }
    @IBOutlet private weak var contentView: UIStackView!
    
    override func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.filterBackColor
        
        parameters.forEach {
            let view = AdjustmentParameterSliderView.with(parameter: $0, delegate: self)
            contentView.addArrangedSubview(view)
        }
    }

    @IBAction private func onHSLTapped(_ sender: UIButton) {
        delegate?.showHSLFilter()
    }
}
