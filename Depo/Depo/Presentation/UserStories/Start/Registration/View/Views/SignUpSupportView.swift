//
//  SignUpSupportView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SignUpSupportViewDelegate: class {
    func openSupport()
}

final class SignUpSupportView: UIView {
    
    private let messageLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.textColor = ColorConstants.whiteColor
        newValue.text = TextConstants.signupSupportInfo
        newValue.numberOfLines = 0
        newValue.isOpaque = true

        return newValue
    }()
    
    private let symbolImageView: UIImageView = {
        let image = UIImage(named: "question_symbol")
        let newValue = UIImageView(image: image)
        newValue.isOpaque = true
        
        
        return newValue
    }()
    
    private let arrowButton: UIButton = {
        let newValue = UIButton()
        
        let image = UIImage(named: "search_arrow")
        newValue.setImage(image, for: .normal)
        newValue.isUserInteractionEnabled = false
        newValue.isOpaque = true
        
        return newValue
    }()
    
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    weak var delegate: SignUpSupportViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSupport))
        self.addGestureRecognizer(tapGesture)
        
        addSubview(arrowButton)
        addSubview(messageLabel)
        addSubview(symbolImageView)

        setupGradient()
        setupLayout()
    }
    
    private func setupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [ColorConstants.alertBlueGradientStart.cgColor,
                                ColorConstants.alertBlueGradientEnd.cgColor]
    }
    
    private func setupLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        
        symbolImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        symbolImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7).isActive = true
        symbolImageView.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16).isActive = true
        symbolImageView.widthAnchor.constraint(equalTo: symbolImageView.heightAnchor, multiplier: 0.6).isActive = true
        
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        arrowButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        arrowButton.heightAnchor.constraint(equalTo: arrowButton.widthAnchor, multiplier: 2).isActive = true
        arrowButton.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 8).isActive = true
    }
    
    @objc private func openSupport() {
        delegate?.openSupport()
    }
}
