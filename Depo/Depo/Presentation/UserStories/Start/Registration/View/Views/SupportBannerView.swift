//
//  SupportBannerView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SupportBannerViewDelegate: class {
    func openSupport()
}

final class SupportBannerView: UIView {
    
    private let messageLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.textColor = ColorConstants.whiteColor
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
    
    var message: String = TextConstants.signupSupportInfo {
        willSet {
            messageLabel.text = newValue
        }
    }
    
    weak var delegate: SupportBannerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        
        layer.cornerRadius = 4
        
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
        translatesAutoresizingMaskIntoConstraints = false

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).activate()
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).activate()
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).activate()

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        
        symbolImageView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        symbolImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7).activate()
        symbolImageView.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8).activate()
        symbolImageView.widthAnchor.constraint(equalTo: symbolImageView.heightAnchor, multiplier: 0.6).activate()
        
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        arrowButton.widthAnchor.constraint(equalToConstant: 24).activate()
        arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
        arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).activate()
        arrowButton.heightAnchor.constraint(equalTo: arrowButton.widthAnchor, multiplier: 2).activate()
        arrowButton.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 8).activate()
    }
    
    @objc private func openSupport() {
        delegate?.openSupport()
    }
}
