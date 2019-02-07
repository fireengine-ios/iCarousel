//
//  UIEdgeInsets+Extensions.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


extension UIEdgeInsets {
    static func make(topBottom: CGFloat, rightLeft: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: topBottom, left: rightLeft, bottom: topBottom, right: rightLeft)
    }
}
