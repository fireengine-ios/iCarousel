//
//  ProfilePasswordEnterView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfilePasswordEnterView: ProfileTextEnterView {
    
    private let showPasswordImage = UIImage(named: "show")
    private let hidePasswordImage = UIImage(named: "hide")
    
    //TODO: change to button
    private let eyeImageView: UIImageView = {
        let newValue = UIImageView()
        newValue.contentMode = .scaleAspectFill
        ///without it tapGuesture not work
        newValue.isUserInteractionEnabled = true
        
        return newValue
    }()
    
    private let topStackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 8
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fill
        
        return newValue
    }()
    
    override func initialSetup() {
        super.initialSetup()
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(changeVisibilityState))
        eyeImageView.addGestureRecognizer(tapGesture)
        eyeImageView.image = showPasswordImage
        
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
    
    override func setupStackView() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        topStackView.addArrangedSubview(titleLabel)
        topStackView.addArrangedSubview(eyeImageView)
        
        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    @objc private func changeVisibilityState() {
        textField.toggleTextFieldSecureType()
        eyeImageView.image = textField.isSecureTextEntry ? showPasswordImage : hidePasswordImage
    }
}
