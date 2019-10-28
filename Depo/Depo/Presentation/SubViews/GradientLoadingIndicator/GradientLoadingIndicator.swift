//
//  GradientLoadingIndicator.swift
//  Depo
//
//  Created by Aleksandr on 7/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

final class GradientLoadingIndicator: UIView {
    let circlePathLayer = CAShapeLayer()
    var circleRadius: CGFloat {
        return bounds.width / 2
    }
    let lineWidth: CGFloat = 14
    
    let gradientView = GradientView()
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    func resetProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circlePathLayer.strokeEnd = 0
        CATransaction.commit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    func configurate() {
        progress = 0
        circlePathLayer.frame = bounds
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circlePathLayer)
        circlePathLayer.lineWidth = lineWidth
        addMaskGradient()
    }
    
    private func addMaskGradient() {
        gradientView.setup(withFrame: bounds, startColor: UIColor.lrCryonBlue, endColoer: UIColor.lrMintGreen, startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0))
        addSubview(gradientView)
        
        gradientView.layer.mask = circlePathLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
        gradientView.update(withFrame: bounds, startColor: UIColor.lrCryonBlue, endColoer: UIColor.lrMintGreen, startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0))
    }
    
    func circleFrame() -> CGRect {
        let circleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2),
                            radius: circleRadius - lineWidth / 2,
                            startAngle: -CGFloat.pi * 3 / 2,
                            endAngle: CGFloat.pi / 2, clockwise: true)
    }
}
