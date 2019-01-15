//
//  LTCircularProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 11/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

@IBDesignable
class LTCircularProgressView: UIView {
    
    private let backgroundCircleLayer = CAShapeLayer()
    private let foregroundCircleLayer = CAShapeLayer()
    
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
            print("RATIO: \(progressRatio)")
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
    
//    @IBInspectable var radius: CGFloat = 64 {
//        didSet {
//            setupLayers()
//        }
//    }
    
    var radius: CGFloat {
        return (min(layer.bounds.width, layer.bounds.height) - max(progressWidth, backWidth)) / 2.0
    }
    
    var innerRadius: CGFloat {
        return radius - max(progressWidth, backWidth) / 2.0
    }
    
    private let oneStepAnimationDuration = 2.0
    private var currentAnimationTime = 0.0
    private var steps: Double = 5
    
    private var timeToAnimateAllSteps: Double {
        return oneStepAnimationDuration * steps
    }
    
    private var progressRatioStep: CGFloat {
        return CGFloat(1.0 / steps)
    }
    
    private lazy var timer: Timer = {
        return Timer.scheduledTimer(timeInterval: oneStepAnimationDuration, target: self, selector: #selector(animateStep), userInfo: nil, repeats: true)
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: - Override
    
    ///IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setupLayers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayers()
    }
    
    
    //MARK: - Setup
    
    private func setupLayers() {
        setupBackgroundCircle()
        setupForegroundCircle()
    }
    
    private func setupBackgroundCircle() {
        backgroundCircleLayer.removeFromSuperlayer()
        
        let arcCenter = convert(center, from: superview)
        let startAngle = -CGFloat.pi/2 ///top point
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundCircleLayer.path = path.cgPath
        backgroundCircleLayer.lineWidth = backWidth
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = backColor.cgColor
        
        layer.insertSublayer(backgroundCircleLayer, at: 0)
    }

    private func setupForegroundCircle() {
        foregroundCircleLayer.removeFromSuperlayer()
        
        let arcCenter = convert(center, from: superview)
        let startAngle = -CGFloat.pi/2 ///top point
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        foregroundCircleLayer.lineCap = kCALineCapRound
        foregroundCircleLayer.path = path.cgPath
        foregroundCircleLayer.lineWidth = progressWidth
        foregroundCircleLayer.fillColor = UIColor.clear.cgColor
        foregroundCircleLayer.strokeColor = progressColor.cgColor
        foregroundCircleLayer.strokeEnd = progressRatio
        
        layer.addSublayer(foregroundCircleLayer)
    }

    
    //MARK: - Animate
    
    func set(progress: CGFloat, withAnimation: Bool, duration: TimeInterval?) {
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
    
    func animateConstantly() {
        timer.fire()
    }
    
    func stopAnimation() {
        timer.invalidate()
    }
    
    
    
    @objc private func animateStep() {
        if currentAnimationTime >= timeToAnimateAllSteps {
            progressRatio = 0.0
            currentAnimationTime = oneStepAnimationDuration
            set(progress: progressRatioStep, withAnimation: true, duration: oneStepAnimationDuration)
        } else {
            currentAnimationTime += oneStepAnimationDuration
            set(progress: progressRatio + progressRatioStep, withAnimation: true, duration: oneStepAnimationDuration)
            ///change photo/captions
        }
    }
}
