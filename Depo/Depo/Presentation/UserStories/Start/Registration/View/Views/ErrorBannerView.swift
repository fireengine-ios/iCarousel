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
        newValue.textColor = ColorConstants.textOrange
        newValue.lineBreakMode = .byWordWrapping
        newValue.numberOfLines = 0
        newValue.text = ""
        newValue.isOpaque = true
        
        return newValue
    }()
    
    @IBInspectable var shouldShowUnderlineLayer = true {
        didSet {
            updateUnderlineLayerVisibility()
        }
    }
    
    private let underlineLayer: CALayer = {
        let newValue = CALayer()
        
        newValue.backgroundColor = ColorConstants.profileGrayColor.cgColor
        
        return newValue
    }()
    
    private let underlineWidth: CGFloat = 1.0
    
    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineLayer.frame = CGRect(x: 0.0,
                                      y: frame.size.height - underlineWidth,
                                      width: frame.width,
                                      height: underlineWidth);
        updateUnderlineLayerVisibility()
    }
    
    private func setup() {
        layer.addSublayer(underlineLayer)
        addSubview(messageLabel)
        
        messageLabel.text = message
        
        setupLayout()
    }
    
    private func setupLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.pinToSuperviewEdges()
        messageLabel.topAnchor.constraint(equalTo: topAnchor).activate()
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).activate()
    }
    
    private func updateUnderlineLayerVisibility() {
        underlineLayer.isHidden = !shouldShowUnderlineLayer
    }
}
