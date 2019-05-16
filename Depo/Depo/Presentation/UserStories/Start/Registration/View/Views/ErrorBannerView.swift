//
//  ErrorBannerView.swift
//  Depo
//
//  Created by Raman Harhun on 4/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class ErrorBannerView: UIView {

    private let messageLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        newValue.textColor = ColorConstants.whiteColor
        newValue.numberOfLines = 0
        newValue.text = ""
        newValue.isOpaque = true
        
        return newValue
    }()
    
    private let symbolImageView: UIImageView = {
        let image = UIImage(named: "exclamation_mark")
        let newValue = UIImageView(image: image)
        newValue.isOpaque = true
        
        
        return newValue
    }()
    
    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        addSubview(messageLabel)
        addSubview(symbolImageView)
        
        messageLabel.text = message
        
        setupGradient()
        setupLayout()
    }
    
    private func setupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [ColorConstants.errorOrangeGradientStart.cgColor,
                                ColorConstants.errorOrangeGradientEnd.cgColor]
    }
    
    private func setupLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        
        symbolImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        symbolImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7).isActive = true
        symbolImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        symbolImageView.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16).isActive = true
        symbolImageView.widthAnchor.constraint(equalTo: symbolImageView.heightAnchor, multiplier: 0.4).isActive = true
    }
}
