//
//  BorderedPasswordEnterView.swift
//  Depo
//
//  Created by Hooman Seven on 11/8/2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class BorderedPasswordEnterView: ProfileTextEnterView {
    
    private let showPasswordImage = Image.iconHideSee.image
    private let hidePasswordImage = Image.iconHideUnselect.image
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
    
    override func setupStackView() {
        super.setupStackView()
        
        textField.addSubview(eyeButton)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        eyeButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -10).isActive = true
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
