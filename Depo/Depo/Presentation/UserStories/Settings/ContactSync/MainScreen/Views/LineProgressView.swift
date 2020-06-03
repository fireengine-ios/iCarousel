//
//  LineProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 03.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class LineProgressView: UIView {
    private let lineWidth: CGFloat = 20.0
    
    private var lineColor: CGColor = UIColor.green.cgColor
    private var lineBackgroundColor: CGColor = UIColor.gray.cgColor
    
    private var linePath: CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY / 2))
        return path.cgPath
    }
    
    private lazy var backLayer: CAShapeLayer = {
        let circleShape = CAShapeLayer()
        circleShape.path = linePath
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.strokeColor = lineBackgroundColor
        circleShape.lineWidth = lineWidth
        circleShape.lineCap = kCALineCapRound

        circleShape.strokeEnd = 1.0
        
        return circleShape
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let progressShape = CAShapeLayer()
        progressShape.path = linePath
        progressShape.fillColor = UIColor.clear.cgColor
        progressShape.strokeColor = lineColor
        progressShape.lineWidth = lineWidth
        progressShape.lineCap = kCALineCapRound
        progressShape.shadowColor = UIColor.black.cgColor
        progressShape.shadowOffset = CGSize(width: 0.0, height: 0.5)
        progressShape.shadowRadius = 2.0
        progressShape.shadowOpacity = 0.5
        progressShape.strokeEnd = 0.0
        
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
            self.backLayer.strokeColor = self.lineBackgroundColor
        }
    }
    
    func set(progress: Int) {
        DispatchQueue.toMain {
//            self.set(percentageValue: progress)
            self.progressLayer.strokeEnd = CGFloat(progress) / 100
        }
    }
    
    func resetProgress() {
        DispatchQueue.toMain {
//            self.set(percentageValue: 0)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.strokeEnd = 0
            CATransaction.commit()
        }
    }
    
    //MARK:- Private
    
    private func setup() {
        self.layer.addSublayer(self.backLayer)
        self.layer.addSublayer(self.progressLayer)
    }
}
