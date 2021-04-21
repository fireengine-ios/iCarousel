//
//  RingView.swift
//  Depo_LifeTech
//
//  Created by user on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class RingView: UIView {
    
    @IBInspectable var mainColor: UIColor = ColorConstants.activityTimelineDraws.color
    @IBInspectable var ringColor: UIColor = ColorConstants.activityTimelineDraws.color
    @IBInspectable var ringThickness: CGFloat = 4
    
    override func draw(_ rect: CGRect) {
        let dotPath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = dotPath.cgPath
        shapeLayer.fillColor = mainColor.cgColor
        layer.addSublayer(shapeLayer)
        
        drawRingFittingInsideView(rect: rect)
    }
    
    internal func drawRingFittingInsideView(rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = ringColor.cgColor
        shapeLayer.lineWidth = ringThickness
        layer.addSublayer(shapeLayer)
    }
}
