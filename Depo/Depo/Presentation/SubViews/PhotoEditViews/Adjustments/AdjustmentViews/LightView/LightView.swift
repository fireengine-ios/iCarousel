//
//  LightView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class LightView: AdjustmentsView, NibInit {

    static func with(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> LightView {
        let view = LightView.initFromNib()
        view.setup(parameters: parameters, delegate: delegate)
        return view
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstaint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstaint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        topConstraint.constant = Device.isIpad ? 30 : 16
        bottomConstraint.constant = Device.isIpad ? 40 : 16
        leadingConstaint.constant = Device.isIpad ? 80 : 0
        trailingConstaint.constant = Device.isIpad ? 80 : 0
    }
    
    override func setup(parameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) {
        super.setup(parameters: parameters, delegate: delegate)
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        
        parameters.forEach {
            let view = AdjustmentParameterSliderView.with(parameter: $0, delegate: self)
            contentView.addArrangedSubview(view)
        }
    }
}
