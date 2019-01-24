//
//  LTCircularProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 11/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

//@IBDesignable
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
        return (min(layer.bounds.width, layer.bounds.height) - max(progressWidth, backWidth)) * 0.5
    }
    
    var innerRadius: CGFloat {
        return min(layer.bounds.width, layer.bounds.height) * 0.5 - max(progressWidth, backWidth)
    }

    private var animationHelper: LTCircularAnimationHelper?
    
    
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
        let startAngle = -CGFloat.pi * 0.5 ///top point
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
        let startAngle = -CGFloat.pi * 0.5 ///top point
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
    
    func animateInfinitely(numberOfSteps: Int, timeForStep: TimeInterval, stepBlock: LTCircularAnimationStepBlock?) {
        animationHelper?.stopAnimation()
        let safeNumberOfSteps = (numberOfSteps == 0) ? 1 : numberOfSteps
        let progressRatioStep: CGFloat = 1.0 / CGFloat(safeNumberOfSteps)
        animationHelper = LTCircularAnimationHelper(with: numberOfSteps, timeForStep: timeForStep, stepBlock: { [weak self] currentStep, isLastStep in
            guard let `self` = self else { return }
            
            self.set(progress: self.progressRatio + progressRatioStep, withAnimation: true, duration: timeForStep)
            
            if isLastStep {
                self.progressRatio = 0.0
            }
            
            stepBlock?(currentStep, isLastStep)
        })
        animationHelper?.animateInfinitely()
    }
}


typealias LTCircularAnimationStepBlock = (_ stepNumber: Int, _ isLastStep: Bool)->Void


final class LTCircularAnimationHelper {
    private var stepCallback: LTCircularAnimationStepBlock?
    
    private lazy var timer: Timer = {
        return Timer.scheduledTimer(timeInterval: stepDuration, target: self, selector: #selector(performAnimationStep), userInfo: nil, repeats: true)
    }()
    
    private var steps = 5
    private var stepDuration = 0.5
    
    private var currentStep = 0
    
    
    init(with numberOfSteps: Int, timeForStep: TimeInterval, stepBlock: @escaping LTCircularAnimationStepBlock) {
        steps = numberOfSteps
        stepDuration = timeForStep
        stepCallback = stepBlock
    }
    
    @objc private func performAnimationStep() {
        let isLastStep = currentStep >= (steps - 1)
        stepCallback?(currentStep, isLastStep)
        currentStep = isLastStep ? 0 : currentStep + 1
    }
    
    func animateInfinitely() {
        timer.fire()
    }
    
    func stopAnimation() {
        timer.invalidate()
    }
}
