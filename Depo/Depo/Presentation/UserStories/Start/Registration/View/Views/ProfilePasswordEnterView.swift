//
//  ProfilePasswordEnterView.swift
//  Depo
//
//  Created by Raman Harhun on 4/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class ProfilePasswordEnterView: ProfileTextEnterView {
    
    private let eyeButton: UIButton = {
        let newValue = UIButton(frame: .zero)
        let showPasswordImage = UIImage(named: "show")
        let hidePasswordImage = UIImage(named: "hide")
        
        newValue.setImage(showPasswordImage, for: .normal)
        newValue.setImage(hidePasswordImage, for: .selected)
        
        return newValue
    }()
    
    private let stackViewForButton: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 8
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fill
        
        return newValue
    }()
    
    override func initialSetup() {
        super.initialSetup()
        
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(changeVisibilityState))
        eyeButton.addGestureRecognizer(tapGesture)
    }
    
    override func setupStackView() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        stackViewForButton.addArrangedSubview(titleLabel)
        stackViewForButton.addArrangedSubview(eyeButton)
        
        stackView.addArrangedSubview(stackViewForButton)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    @objc private func changeVisibilityState() {
        eyeButton.isSelected.toggle()
        textField.toggleTextFieldSecureType()
    }
}
