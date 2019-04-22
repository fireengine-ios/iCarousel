//
//  InstaPickCircularLoader.swift
//  Depo
//
//  Created by Konstantin Studilin on 01/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

final class InstaPickCircularLoader: CircleProgressView, FromNib {
    
    @IBOutlet private var backgroundView: UIView! {
        didSet {
            backgroundView.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var image: UIImageView! {
        didSet {
            image.backgroundColor = .clear
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
        }
    }
    
    private var animationHelper: LTCircularAnimationHelper?
    
    //MARK: - Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupFromNib()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        setupImageMask()
    }
    
    //MARK: - Setup

    private func setupImageMask() {
        let inset: CGFloat = 4.0
        let diameter = (innerRadius - inset) * 2.0
        let startPoint = (image.bounds.width - diameter) * 0.5

        let maskLayerRect = CGRect(x: startPoint, y: startPoint,
                                   width: diameter,
                                   height: diameter)
        let ovalPath = UIBezierPath(ovalIn: maskLayerRect)
        let maskLayer = CAShapeLayer()
        maskLayer.path = ovalPath.cgPath
        
        image.layer.mask = maskLayer
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
