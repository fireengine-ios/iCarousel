//
//  GradientOrangeView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 5/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class GradientOrangeView: UIView {
    
    private let gradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let colorTop = ColorConstants.orangeGradientStart
        let colorBottom = ColorConstants.orangeGradientEnd
        
        gradient.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = bounds
    }
}
