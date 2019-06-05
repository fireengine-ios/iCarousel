//
//  ProfilePasswordEnterView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfilePasswordEnterView: ProfileTextEnterView {
    
    private let showPasswordImage = UIImage(named: "ic_eye_show")
    private let hidePasswordImage = UIImage(named: "ic_eye_hide")
    private let eyeSize: CGFloat = 44
    
    private let eyeButton = UIButton()
    
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
        
        eyeButton.setImage(showPasswordImage, for: .normal)
        eyeButton.setImage(hidePasswordImage, for: .selected)
        eyeButton.addTarget(self, action: #selector(changeVisibilityState), for: .touchUpInside)
        
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
        topStackView.addArrangedSubview(eyeButton)
        
        eyeButton.widthAnchor.constraint(equalToConstant: eyeSize).isActive = true
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    @objc private func changeVisibilityState() {
        textField.toggleTextFieldSecureType()
        eyeButton.isSelected.toggle()
    }
}
