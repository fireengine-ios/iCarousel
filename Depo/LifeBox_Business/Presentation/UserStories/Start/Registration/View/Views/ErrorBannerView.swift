//
//  ErrorBannerView.swift
//  Depo
//
//  Created by Raman Harhun on 4/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class ErrorBannerView: UIView {

    var errorLabelTextColor: UIColor = ColorConstants.textOrange.color {
        didSet {
            messageLabel.textColor = errorLabelTextColor
        }
    }

    var errorLabelTextFont: UIFont {
        get {
            return messageLabel.font
        }

        set {
            messageLabel.font = newValue
        }
    }

    var errorTextAlignment: NSTextAlignment {
        get {
            return messageLabel.textAlignment
        }

        set {
            messageLabel.textAlignment = newValue
        }
    }

    private lazy var messageLabel: UILabel = {
        let newValue = UILabel()
        newValue.font = UIFont.GTAmericaStandardDemiBoldFont(size: 16)
        newValue.textColor = errorLabelTextColor
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
        
        newValue.backgroundColor = ColorConstants.profileGrayColor.color.cgColor
        
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
        
        messageLabel.text = ""
        
        setupLayout()
    }
    
    private func setupLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.topAnchor.constraint(equalTo: topAnchor).activate()
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).activate()
    }
    
    private func updateUnderlineLayerVisibility() {
        underlineLayer.isHidden = !shouldShowUnderlineLayer
    }
}
