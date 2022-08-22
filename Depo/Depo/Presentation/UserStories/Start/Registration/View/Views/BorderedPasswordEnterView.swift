//
//  BorderedPasswordEnterView.swift
//  Depo
//
//  Created by Hooman Seven on 11/8/2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class BorderedPasswordEnterView: BorderedTextEnterView {
    
    private let showPasswordImage = Image.iconHideSee.image
    private let hidePasswordImage = UIImage(named: "ic_eye_hide")
    private let eyeSize: CGFloat = 44
    private let eyeButton = UIButton()
    
    override func initialSetup() {
        super.initialSetup()

        eyeButton.setImage(showPasswordImage, for: .normal)
        eyeButton.setImage(hidePasswordImage, for: .selected)
        eyeButton.addTarget(self, action: #selector(changeVisibilityState), for: .touchUpInside)
        updatePasswordButtonAccessibility()
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
    
    override func setupViews() {
        addSubview(holderView)
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        holderView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        holderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        holderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        holderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        holderView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: holderView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: holderView.leadingAnchor, constant: 12),
            titleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        holderView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 12
        stackView.topAnchor.constraint(equalTo: holderView.topAnchor, constant: 25).isActive = true
        stackView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor, constant: -4).isActive = true
        
        holderView.addSubview(eyeButton)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        
        eyeButton.widthAnchor.constraint(equalToConstant: eyeSize).isActive = true
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        eyeButton.centerYAnchor.constraint(equalTo: holderView.centerYAnchor, constant: 10).isActive = true
        eyeButton.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -16).isActive = true

        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textField)
    }

    @objc private func changeVisibilityState() {
        textField.toggleTextFieldSecureType()
        eyeButton.isSelected.toggle()
        updatePasswordButtonAccessibility()
    }

    private func updatePasswordButtonAccessibility() {
        eyeButton.accessibilityLabel = eyeButton.isSelected ? TextConstants.hidePassword : TextConstants.showPassword
    }
}
