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
        
    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func initialSetup() {
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).activate()
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).activate()
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).activate()
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).activate()
    }
}
