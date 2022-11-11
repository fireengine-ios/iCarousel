//
//  CreateStoryMusicEnterView.swift
//  Depo
//
//  Created by Raman Harhun on 6/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryMusicEnterView: ProfileTextEnterView {
    
    var action: VoidHandler?
    
    override func initialSetup() {
        super.initialSetup()
        
        setupView()
    }
    
    private func setupView() {
        let arrowImageView = UIImageView(image: Image.iconArrowRightsmall.image)
        
        addSubview(arrowImageView)
        
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: -12).activate()
        arrowImageView.heightAnchor.constraint(equalToConstant: 24).activate()
        arrowImageView.widthAnchor.constraint(equalToConstant: 24).activate()
        arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).activate()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(gesture)
    }
    
    @objc private func tapAction() {
        action?()
    }
}
