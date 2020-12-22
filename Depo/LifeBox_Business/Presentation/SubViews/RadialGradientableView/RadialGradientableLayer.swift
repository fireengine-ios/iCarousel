//
//  RadialGradientableLayer.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class RadialGradientableLayer: CALayer {
    
    var gradientColors: [CGColor] = InstaPickGradient.gradientColors {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isNeedGradient: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var center: CGPoint {
        return CGPoint(x: bounds.width, y: 0)
    }
    
    var radius: CGFloat {
        ///Pythagorean theorem
        return sqrt(pow(bounds.width, 2) + pow(bounds.height, 2))
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func draw(in ctx: CGContext) {
        guard isNeedGradient else {
            return
        }
        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: gradientColors as CFArray,
                                        locations: InstaPickGradient.locations)
        else {
            return
        }
        ctx.drawRadialGradient(gradient,
                               startCenter: center,
                               startRadius: 0.0,
                               endCenter: center,
                               endRadius: radius,
                               options: CGGradientDrawingOptions(rawValue: 0))
    }
    
    //Utility Method
    private func setup() {
        needsDisplayOnBoundsChange = true
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
