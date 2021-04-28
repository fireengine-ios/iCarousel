//
//  UIStackView+Extensions.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//


extension UIStackView {
    
    /// https://stackoverflow.com/a/33929062/5893286
    func addSubviewWith(backgroundColor: UIColor, cornerRadius: CGFloat) {
        let backgroundView = UIView(frame: bounds)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = backgroundColor
        insertSubview(backgroundView, at: 0)
        
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.layer.masksToBounds = true
    }
}
