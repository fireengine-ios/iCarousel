//
//  MediaContentGradientView.swift
//  Depo
//
//  Created by Konstantin Studilin on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class MediaContentGradientView: UIView {
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.locations = [0, 0.15, 0.85, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        
        return layer
    }()
    
    //MARK: Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        setupLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    func toggleVisibility() {
        set(isHidden: !gradientLayer.isHidden, animated: true)
    }
    
    func set(isHidden: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let animationDuration = animated ? NumericConstants.animationDuration : 0
            UIView.animate(withDuration: animationDuration) {
                self.gradientLayer.isHidden = isHidden
                self.layoutIfNeeded()
            }
        }
    }
    
    //MARK: Private
    
    private func setupLayer() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        layer.addSublayer(gradientLayer)
    }
}
