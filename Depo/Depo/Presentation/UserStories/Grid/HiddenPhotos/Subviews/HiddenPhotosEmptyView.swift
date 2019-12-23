//
//  HiddenPhotosEmptyView.swift
//  Depo
//
//  Created by Andrei Novikau on 12/16/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HiddenPhotosEmptyView: UIView, NibInit {

    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.hiddenBinEmpty
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 24)
        }
    }
    
    @IBOutlet private weak var topOffsetConstraint: NSLayoutConstraint!
    
    var topOffset: CGFloat {
        get {
            return topOffsetConstraint.constant
        }
        set {
            topOffsetConstraint.constant = newValue
            layoutIfNeeded()
        }
    }
    
}
