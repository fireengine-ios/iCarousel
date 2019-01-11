//
//  RadialGradientLayer.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class RadialGradientLayer: CALayer {
    
    var isNeedGradient: Bool = true {
        didSet {
            colors = isNeedGradient ? InstaPickGradient.gradientColors : [UIColor.white.cgColor]
        }
    }
    
    var center: CGPoint {
        return CGPoint(x: bounds.width, y: 0)
    }
    
    var radius: CGFloat {
        ///Pythagorean theorem
        return sqrt(pow(bounds.width, 2) + pow(bounds.height, 2))
    }
    
    var colors: [CGColor] = InstaPickGradient.gradientColors {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(){
        super.init()
        
        needsDisplayOnBoundsChange = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }

    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: colors as CFArray,
                                        locations: InstaPickGradient.locations) else {
            return
        }
        ctx.drawRadialGradient(gradient,
                               startCenter: center,
                               startRadius: 0.0,
                               endCenter: center,
                               endRadius: radius,
                               options: CGGradientDrawingOptions(rawValue: 0))
    }
}

private enum InstaPickGradient {
    static let gradientColors: [CGColor] = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor, fouthColor.cgColor]
    
    static let firstColor   = UIColor(red: 81/255, green: 91/255, blue: 212/255, alpha: 1)
    static let secondColor   = UIColor(red: 194/255, green: 12/255, blue: 111/255, alpha: 1)
    static let thirdColor  = UIColor(red: 240/255, green: 78/255, blue: 41/255, alpha: 1)
    static let fouthColor   = UIColor(red: 250/255, green: 214/255, blue: 105/255, alpha: 1)
    
    static let locations: [CGFloat] = [0.0, 0.2, 0.8, 1]
}
