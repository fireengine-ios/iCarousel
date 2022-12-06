//
//  InstaPickLineLoader.swift
//  Depo
//
//  Created by yilmaz edis on 14.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class InstaPickLineLoader: UIView {
    
    lazy var imageContainer: UIView = {
       let view = UIView()
        
        return view
    }()
    
    lazy var image: UIImageView = {
       let view = UIImageView()
        
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 3
        view.layer.borderColor = AppColor.button.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    lazy var lineLoader: UIProgressView = {
       let view = UIProgressView()
        view.progressTintColor = AppColor.button.color
        view.trackTintColor = AppColor.lightGrayColor.color
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.layer.borderColor = AppColor.lightGrayColor.cgColor
        
        var transform : CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        view.transform = transform
        return view
    }()
    
    private var animationHelper: LTCircularAnimationHelper?
    private var progressRatio: CGFloat = 0.0 {
        didSet {
            let optimisedValue = min(max(progressRatio, 0.0), 1.0)
            if progressRatio != optimisedValue {
                progressRatio = optimisedValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.topAnchor.constraint(equalTo: topAnchor).activate()
        image.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        image.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        
        addSubview(lineLoader)
        lineLoader.translatesAutoresizingMaskIntoConstraints = false
        lineLoader.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 16).activate()
        lineLoader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11).activate()
        lineLoader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11).activate()
        lineLoader.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
        
        lineLoader.heightAnchor.constraint(equalToConstant: 6).activate()
    }
    
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
    
    func set(progress: CGFloat) {
        self.lineLoader.setProgress(Float(progress), animated: true)
        progressRatio = progress
    }
    
    func animateInfinitely(numberOfSteps: Int, timeForStep: TimeInterval, stepBlock: LTCircularAnimationStepBlock?) {
        animationHelper?.stopAnimation()
        let safeNumberOfSteps = (numberOfSteps == 0) ? 1 : numberOfSteps
        let progressRatioStep: CGFloat = 1.0 / CGFloat(safeNumberOfSteps)
        animationHelper = LTCircularAnimationHelper(with: numberOfSteps, timeForStep: timeForStep, stepBlock: { [weak self] currentStep, isLastStep in
            guard let `self` = self else { return }

            self.set(progress: self.progressRatio + progressRatioStep)
            
            if isLastStep {
                self.progressRatio = 0.0
            }
            
            stepBlock?(currentStep, isLastStep)
        })
        animationHelper?.animateInfinitely()
    }
}
