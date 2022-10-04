//
//  ProfilePasswordEnterView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class ProfilePasswordEnterView: ProfileTextEnterView {
    
    private let showPasswordImage = Image.iconHideSee.image
    private let hidePasswordImage = Image.iconHideUnselect.image
    private let eyeSize: CGFloat = 24
    
    private lazy var eyeButton: UIButton = {
       let view = UIButton()
        view.setImage(showPasswordImage, for: .normal)
        view.setImage(hidePasswordImage, for: .selected)
        return view
    }()
    
    override func initialSetup() {
        super.initialSetup()
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
        eyeButton.widthAnchor.constraint(equalToConstant: eyeSize).isActive = true
        eyeButton.heightAnchor.constraint(equalToConstant: eyeSize).isActive = true
        eyeButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        eyeButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16).isActive = true
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
