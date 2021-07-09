//
//  AnimatedCircularLoader.swift
//  Depo
//
//  Created by Konstantin Studilin on 14.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AnimatedCircularLoader: UIView {

    private var lineWidth: CGFloat {
        return bounds.width / 10.0
    }
    
    private var lineColor: CGColor = UIColor.green.cgColor
    private var lineBackgroundColor: CGColor = UIColor.gray.cgColor
    
    private var radius: CGFloat {
        return bounds.midY - lineWidth / 2.0
    }
    
    private var animationDuration: Double = 1
    
    
    private var circlePath: CGPath {
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = CGFloat(3.0 * .pi / 2.0)
        let endAngle = CGFloat(startAngle + 2.0 * .pi)
        
        return UIBezierPath(arcCenter: arcCenter, radius: radius,
                            startAngle: startAngle, endAngle: endAngle,
                            clockwise: true).cgPath
    }
    
    private lazy var backCircleLayer: CAShapeLayer = {
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.strokeColor = lineBackgroundColor
        circleShape.lineWidth = lineWidth
        circleShape.lineCap = .butt

        circleShape.strokeEnd = 1.0
        
        return circleShape
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressShape = CAShapeLayer()
        progressShape.path = circlePath
        progressShape.fillColor = UIColor.clear.cgColor
        progressShape.strokeColor = lineColor
        progressShape.lineWidth = lineWidth
        progressShape.lineCap = .round
        progressShape.shadowColor = UIColor.black.cgColor
        progressShape.shadowOffset = CGSize(width: 0.5, height: 0.5)
        progressShape.shadowRadius = lineWidth / 8.0
        progressShape.shadowOpacity = 0.5
        progressShape.strokeEnd = 0.75
        
        return progressShape
    }()

    
    //MARK:- Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayers()
    }
    
    
    //MARK:- Public
    
    func set(lineColor: UIColor) {
        DispatchQueue.toMain {
            self.lineColor = lineColor.cgColor
            self.progressLayer.strokeColor = self.lineColor
        }
    }
    
    func set(lineBackgroundColor: UIColor) {
        DispatchQueue.toMain {
            self.lineBackgroundColor = lineBackgroundColor.cgColor
            self.backCircleLayer.strokeColor = self.lineBackgroundColor
        }
    }
    
    
    func set(duration: Double) {
        DispatchQueue.toMain {
            self.animationDuration = duration
        }
    }
    
    func startAnimation() {
        guard layer.animation(forKey: "rotation") == nil else {
            return
        }
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0.0
        rotation.toValue = Double.pi * 2.0
        rotation.duration = animationDuration
        rotation.repeatCount = .infinity
        
        layer.add(rotation, forKey: "rotation")
    }
    
    func stopAnimation() {
        layer.removeAllAnimations()
    }
    
    
    //MARK:- Private
    
    private func setup() {
        layer.addSublayer(self.backCircleLayer)
        layer.addSublayer(self.progressLayer)
        
        setupObservers()
    }
    
    private func updateLayers() {
        backCircleLayer.path = circlePath
        progressLayer.path = circlePath
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        startAnimation()
    }
    
    @objc private func willResignActive() {
        stopAnimation()
    }
    
}

