//
//  InstaPickCircularLoader.swift
//  Depo
//
//  Created by Konstantin Studilin on 01/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


class InstaPickCircularLoader: UIView, FromNib {
    
    private let backgroundCircleLayer = CAShapeLayer()
    private let foregroundCircleLayer = CAShapeLayer()
    
    
    @IBOutlet private weak var image: UIImageView! {
        didSet {
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
        }
    }
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        setupFromNib()
        
        setupBackgroundCircle()
        setupForegroundCircle()
        setupImage()
    }
    
    
    //MARK: - Setup

    
    private func setupImage() {
//        let inset: CGFloat = 8.0
//        let diameter = (innerRadius - inset) * 2.0
//        let startPoint = (image.layer.bounds.width - diameter) * 0.5
//
//        let maskLayerRect = CGRect(x: startPoint, y: startPoint, width: diameter, height: diameter)
        let ovalPath = UIBezierPath(ovalIn: layer.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.path = ovalPath.cgPath
        
        image.layer.mask = maskLayer
    }
    
    private func setupBackgroundCircle() {
        backgroundCircleLayer.removeFromSuperlayer()
        
//        let arcCenter = convert(center, from: superview)
        let arcCenter = CGPoint(x: layer.bounds.width * 0.5, y: layer.bounds.height * 0.5)
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
        
//        let arcCenter = convert(center, from: superview)
        let arcCenter = CGPoint(x: layer.bounds.width * 0.5, y: layer.bounds.height * 0.5)
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
    
    func set(imageUrl: URL?, animated: Bool) {
        if animated {
            image.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.avoidAutoSetImage], completed: { [weak self] image, error, cahceType, _ in
                guard let `self` = self else {
                    return
                }
                
                UIView.transition(with: self.image,
                                  duration: NumericConstants.instaPickImageViewTransitionDuration,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.image.image = image
                }, completion: nil)
            })
        } else {
            image.sd_setImage(with: imageUrl, completed: nil)
        }
    }
    
    
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
