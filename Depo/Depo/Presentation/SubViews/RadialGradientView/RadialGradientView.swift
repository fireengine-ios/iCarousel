//
//  RadialGradientView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class RadialGradientView: UIView {
    
    var isNeedGradient: Bool = true {
        didSet {
            guard let layer = layer as? RadialGradientLayer else { return }
            layer.isNeedGradient = isNeedGradient
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        return RadialGradientLayer.self
    }
}
