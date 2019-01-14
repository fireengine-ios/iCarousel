//
//  RadialGradientableView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class RadialGradientableView: UIView {
    
    var isNeedGradient: Bool = true {
        didSet {
            guard let layer = layer as? RadialGradientableLayer else { return }
            layer.isNeedGradient = isNeedGradient
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        return RadialGradientableLayer.self
    }
}
