//
//  CircleLoaderView.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class CircleLoaderView: UIView {
    
    private let lineWidth: CGFloat = 14.0
    
    private var lineColor: CGColor = UIColor.green.cgColor
    private var lineBackgroundColor: CGColor = UIColor.gray.cgColor
    
    private var radius: CGFloat {
        return bounds.midY - lineWidth / 2.0
    }
    
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
        circleShape.lineCap = kCALineCapButt
        
        circleShape.shadowPath = circlePath
        circleShape.shadowColor = UIColor.gray.cgColor
        circleShape.shadowRadius = lineWidth + 2.0
        circleShape.strokeEnd = 1.0
        
        return circleShape
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressShape = CAShapeLayer()
        progressShape.path = circlePath
        progressShape.fillColor = UIColor.clear.cgColor
        progressShape.strokeColor = lineColor
        progressShape.lineWidth = lineWidth
        progressShape.lineCap = kCALineCapRound
        progressShape.shadowPath = circlePath
        progressShape.shadowColor = UIColor.black.cgColor
        progressShape.shadowRadius = lineWidth + 2.0
        progressShape.strokeEnd = 0.5
        
        return progressShape
    }()
    
    
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
    }
    
    
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
    
    func set(progressRatio: Float) {
        progressLayer.strokeEnd = CGFloat(progressRatio)
    }
    
    func resetProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 0
        CATransaction.commit()
    }
    
    
    private func setup() {
        layer.addSublayer(backCircleLayer)
        layer.addSublayer(progressLayer)
    }
    
    
}
