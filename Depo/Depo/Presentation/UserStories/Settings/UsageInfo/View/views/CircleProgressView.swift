//
//  CircleProgressView.swift
//  Depo
//
//  Created by Raman Harhun on 3/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class CircleProgressView: UIView {

    private let backgroundCircleLayer = CAShapeLayer()
    private let foregroundCircleLayer = CAShapeLayer()
    private let gradient = CAGradientLayer()
    
    private let circleLayer = CAShapeLayer()
    
    //MARK: - @IBInspectable
    
    //MARK: Foreground
    @IBInspectable var progressWidth: CGFloat = 1.0 {
        didSet {
            foregroundCircleLayer.lineWidth = progressWidth
        }
    }
    
    @IBInspectable var progressColor: UIColor = .red {
        didSet {
            foregroundCircleLayer.strokeColor = progressColor.cgColor
        }
    }
    
    @IBInspectable var progressRatio: CGFloat = 0.5 {
        didSet {
            let optimisedValue = min(max(progressRatio, 0.0), 1.0)
            if progressRatio != optimisedValue {
                progressRatio = optimisedValue
            }
            
            #if TARGET_INTERFACE_BUILDER
            foregroundCircleLayer.strokeEnd = optimisedValue
            #else
            ///
            #endif
        }
    }
    
    //MARK: Background
    
    @IBInspectable var backWidth: CGFloat = 1.0 {
        didSet {
            backgroundCircleLayer.lineWidth = backWidth
        }
    }
    
    @IBInspectable var backColor: UIColor = .gray {
        didSet {
            backgroundCircleLayer.strokeColor = backColor.cgColor
        }
    }
    
    var radius: CGFloat {
        return (min(bounds.width, bounds.height) - max(progressWidth, backWidth)) * 0.5
    }
    
    var innerRadius: CGFloat {
        return min(bounds.width, bounds.height) * 0.5 - max(progressWidth, backWidth)
    }
    
    //MARK: - Override
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        setupBackgroundCircle()
        setupForegroundCircle()
        setupCircle()
    }
    
    //MARK: - Utility Methods(public)
    func set(progress: CGFloat, withAnimation: Bool, duration: TimeInterval? = nil) {
        if withAnimation, let interval = duration {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressRatio
            animation.toValue = progress
            animation.duration = interval
            foregroundCircleLayer.add(animation, forKey: "foregroundAnimation")
        } else {
            foregroundCircleLayer.strokeEnd = progress
        }
        
        progressRatio = progress
    }
    
    //MARK: - Utility Methods(private)
    private func setupBackgroundCircle() {
        backgroundCircleLayer.removeFromSuperlayer()
        
        let arcCenter = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        let startAngle = -CGFloat.pi * 0.5 ///top point
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundCircleLayer.path = path.cgPath
        backgroundCircleLayer.lineWidth = backWidth
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = backColor.cgColor
        
        layer.insertSublayer(backgroundCircleLayer, at: 0)
    }
    
    private func setupCircle() {
        circleLayer.removeFromSuperlayer()
        
        let arcCenter = CGPoint(x: bounds.width * 0.5, y: 4.5)
        let startAngle = -CGFloat.pi * 0.5 ///top point
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(arcCenter: arcCenter, radius: 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = path.cgPath
        circleLayer.lineWidth = backWidth
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.strokeColor = backColor.cgColor
        
        layer.addSublayer(circleLayer)
    }
    
    private func setupForegroundCircle() {
        gradient.removeFromSuperlayer()
        
        layer.cornerRadius = bounds.size.height / 2.0
        clipsToBounds = true
        
        let arcCenter = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        let startAngle = -CGFloat.pi * 0.5 ///top point
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        foregroundCircleLayer.lineCap = .round
        foregroundCircleLayer.path = path.cgPath
        foregroundCircleLayer.lineWidth = progressWidth
        foregroundCircleLayer.fillColor = UIColor.clear.cgColor
        foregroundCircleLayer.strokeColor = progressColor.cgColor
        foregroundCircleLayer.strokeEnd = progressRatio
        
        gradient.frame = bounds
        gradient.colors = [AppColor.progressFront.cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        gradient.mask = foregroundCircleLayer
        //Finally add the gradient layer to out View
        layer.addSublayer(gradient)
    }
}
