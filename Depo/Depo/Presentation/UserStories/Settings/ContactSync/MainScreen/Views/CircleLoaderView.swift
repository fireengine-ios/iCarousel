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
        progressShape.shadowRadius = 2.0
        progressShape.shadowOpacity = 0.5
        progressShape.strokeEnd = 0.0
        
        return progressShape
    }()
    
    private lazy var percentageText: UILabel = {
        let text = UILabel()
        
        text.attributedText = attributedPercentageString(value: 0)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        text.numberOfLines = 0
        text.sizeToFit()
        
        return text
    }()
    
    private let attributedPercentageValue: NSMutableAttributedString = {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.medium, size: 48.0),
            .foregroundColor: AppColor.label.color]
        
        let attributed = NSMutableAttributedString(string: "0", attributes: attributes)
        
        return attributed
    }()
    
    private let attributedPercentageSign: NSAttributedString = {
        let bigFont = UIFont.appFont(.medium, size: 60.0)
        let smallFont = UIFont.appFont(.medium, size: 20.0)
        
        /// percent sign is aligned to top
        let offset = bigFont.capHeight - smallFont.capHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: smallFont,
            .foregroundColor: AppColor.navyAndWhite.color,
            .baselineOffset : offset]
        
        let attributed = NSMutableAttributedString(string: "%", attributes: attributes)
        
        return attributed
    }()
   
    private var currentValue = 0
    
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
    
    func set(progress: Int) {
        guard currentValue != progress else {
            return
        }
        currentValue = progress
        
        DispatchQueue.toMain {
            self.set(percentageValue: progress)
            self.progressLayer.strokeEnd = CGFloat(progress) / 100
        }
    }
    
    func resetProgress() {
        DispatchQueue.toMain {
            self.set(percentageValue: 0)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.strokeEnd = 0
            CATransaction.commit()
        }
    }
    
    
    //MARK:- Private
    
    private func setup() {
        self.layer.addSublayer(self.backCircleLayer)
        self.layer.addSublayer(self.progressLayer)
        
        self.addSubview(self.percentageText)
        
        self.percentageText.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.0).activate()
        self.percentageText.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).activate()
    }
    
    private func updateLayers() {
        backCircleLayer.path = circlePath
        progressLayer.path = circlePath
    }
    
    
    private func set(percentageValue: Int) {
        percentageText.attributedText = attributedPercentageString(value: percentageValue)
    }
    
    private func attributedPercentageString(value: Int) -> NSMutableAttributedString {
        attributedPercentageValue.mutableString.setString("\(value)")
        let result = attributedPercentageValue
        result.append(attributedPercentageSign)
        return result
    }
    
}
