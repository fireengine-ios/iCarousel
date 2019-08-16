//
//  EmailVerifiedPopUp.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 8/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class EmailVerifiedPopUp: UIViewController {
    
    private static let buttonCornerRadius: CGFloat = 22 //button.frame.height / 2
    
    private var image: PopUpImage?
    private var message: String?
    private var buttonTitle: String?
    private var buttonAction: VoidHandler?
    
    private let contentView: UIView = {
        let newValue = UIView(frame: .zero)
        
        newValue.layer.cornerRadius = 4
        newValue.backgroundColor = .white
        
        newValue.layer.shadowOffset = .zero
        newValue.layer.shadowOpacity = 0.5
        newValue.layer.shadowRadius = 4
        newValue.layer.shadowColor = UIColor.black.cgColor
        
        return newValue
    }()
    
    private let imageView: UIImageView = {
        let newValue = UIImageView()
        
        newValue.contentMode = .scaleAspectFit
        
        return newValue
    }()
    
    private let titleLabel: UILabel = {
        let newValue = UILabel()
        
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        newValue.textAlignment = .center
        newValue.numberOfLines = 0
        
        return newValue
    }()
    
    private let button: UIButton = {
        let newValue = UIButton()
        
        newValue.layer.cornerRadius = EmailVerifiedPopUp.buttonCornerRadius
        
        newValue.layer.borderColor = UIColor.lrTealish.cgColor
        newValue.layer.borderWidth = 1
        
        newValue.setBackgroundColor(.white, for: .normal)
        newValue.setTitleColor(UIColor.lrTealish, for: .normal)
        newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
        
        newValue.addTarget(self, action: #selector(onContinueTap), for: .touchUpInside)
        
        return newValue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        setupDesign()
        setupConstraints()
    }
    
    private func setupDesign() {
        view.backgroundColor = ColorConstants.popUpBackground
        
        imageView.image = image?.image
        titleLabel.text = message
        button.setTitle(buttonTitle, for: .normal)
    }
    
    private func setupConstraints() {
        view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
        contentView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32).activate()
        
        contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).activate()
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).activate()
        imageView.heightAnchor.constraint(equalToConstant: 70).activate()
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).activate()
        
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).activate()
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16).activate()
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).activate()
        
        contentView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).activate()
        button.heightAnchor.constraint(equalToConstant: 44).activate()
        button.widthAnchor.constraint(equalToConstant: 146).activate()
        button.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 50)
        button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).activate()
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).activate()
    }
    
    @objc private func onContinueTap() {
        dismiss(animated: true) {
            self.buttonAction?()
        }
    }
}

//MARK: - Init
extension EmailVerifiedPopUp {
    
    static func with(image: PopUpImage, message: String, buttonTitle: String, buttonAction: VoidHandler?) -> EmailVerifiedPopUp {
        let controller = EmailVerifiedPopUp()
        
        controller.image = image
        controller.message = message
        controller.buttonTitle = buttonTitle
        controller.buttonAction  = buttonAction
        
        return controller
    }
    
}
