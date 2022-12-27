//
//  SnackBarHeaderTwoLineView.swift
//  Depo
//
//  Created by yilmaz edis on 8.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class SnackBarHeaderTwoLineView: UIView {
    
    var action: VoidHandler?
    
    lazy var titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = AppColor.label.color
        newValue.backgroundColor = AppColor.background.color
        newValue.font = .appFont(.light, size: 14.0)
        newValue.isOpaque = true
        newValue.numberOfLines = 0
        newValue.setContentCompressionResistancePriority(.required, for: .horizontal)
        newValue.sizeToFit()
        return newValue
    }()
    
    lazy var textField: QuickDismissPlaceholderTextField = {
        let newValue = QuickDismissPlaceholderTextField()
        newValue.textColor = AppColor.label.color
        newValue.font = .appFont(.regular, size: 14.0)
        newValue.backgroundColor = AppColor.background.color
        newValue.isOpaque = true
        newValue.returnKeyType = .next
        return newValue
    }()
    
    lazy var stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 8
        newValue.axis = .vertical
        newValue.alignment = .fill
        newValue.distribution = .fill
        newValue.isOpaque = true
        return newValue
    }()
    
    lazy var arrowImageView: UIImageView = {
        let view = UIImageView(image: Image.iconArrowRightsmall.image)
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        setupStackView()
        setupTapGesture()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
    }
    
    private func setupTapGesture() {
        stackView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).activate()
        arrowImageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).activate()
        arrowImageView.heightAnchor.constraint(equalToConstant: 24).activate()
        arrowImageView.widthAnchor.constraint(equalToConstant: 24).activate()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(gesture)
    }
    
    @objc private func tapAction() {
        action?()
    }
}
