//
//  RadialGradientableView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class RadialGradientableView: UIView {
    
    var gradientColors: [CGColor] {
        get { return viewLayer.gradientColors }
        set { viewLayer.gradientColors = newValue }
    }
    
    lazy var viewLayer: RadialGradientableLayer = {
        if let layer = layer as? RadialGradientableLayer {
            return layer
        } else {
            assertionFailure("in 'class var layerClass' must be RadialGradientableLayer")
            return RadialGradientableLayer()
        }
    }()
    
    var isNeedGradient: Bool {
        get { return viewLayer.isNeedGradient }
        set { viewLayer.isNeedGradient = newValue }
    }
    
    override class var layerClass: Swift.AnyClass {
        return RadialGradientableLayer.self
    }
}
