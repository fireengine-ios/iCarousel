//
//  UIView+Utils.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIView {
    func setSubviewsHidden(_ isHidden: Bool) {
        subviews.forEach({ $0.isHidden = isHidden })
    }

    var frameOnWindow: CGRect {
        guard let superview = superview, let window = window else {
            return frame
        }
        return superview.convert(frame, to: window)
    }
    
    func pinToSuperviewEdges(offset: CGFloat = 0.0) {
        guard let superview = superview else {
            assertionFailure()
            return
        }
        topAnchor.constraint(equalTo: superview.topAnchor, constant: offset).activate()
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: offset).activate()
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset).activate()
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: offset).activate()
    }
}
