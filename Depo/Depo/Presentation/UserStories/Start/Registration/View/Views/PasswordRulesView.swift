//
//  PasswordValidationView.swift
//  Depo
//
//  Created by Burak Donat on 12.07.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

enum PasswordRuleStatus {
    case unedited
    case valid
    case invalid
}

final class PasswordRulesView: UIView {

    var status: PasswordRuleStatus = .unedited {
        didSet {
            configureRuleStatus(with: status)
        }
    }

    private let stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 22
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fillProportionally

        return newValue
    }()

    let imageView: UIImageView = {
        let newValue = UIImageView()
        newValue.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            newValue.image = UIImage(systemName: "dot.circle.fill") //TODO: change it with the real asset
            newValue.image = newValue.image?.resizeImage(rect: CGSize(width: 7, height: 7))
            newValue.image = newValue.image?.withTintColor(ColorConstants.lightGrayColor)
        } else {
            // Fallback on earlier versions
        }
        return newValue
    }()

    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = ColorConstants.lightText
        newValue.font = UIFont.TurkcellSaturaFont(size: 16)
        newValue.backgroundColor = .white
        newValue.isOpaque = true
        newValue.numberOfLines = 0
        return newValue
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    func initialSetup() {
        setupStackView()
    }

    private func setupStackView() {
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true

        /// why it is not working instead of constraints???
        //stackView.frame = bounds
        //stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //stackView.translatesAutoresizingMaskIntoConstraints = true

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
    }

    private func configureRuleStatus(with status: PasswordRuleStatus) {
        switch status {
        case .invalid:
            titleLabel.textColor = ColorConstants.invalidPasswordRule
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "xmark") //TODO: change it with the real asset
                imageView.image = imageView.image?.resizeImage(rect: CGSize(width: 10, height: 10))
                imageView.image = imageView.image?.withTintColor(ColorConstants.invalidPasswordRule)
            } else {
                // Fallback on earlier versions
            }
        case .valid:
            titleLabel.textColor = ColorConstants.switcherGreenColor
            imageView.image = imageView.image?.resizeImage(rect: CGSize(width: 11, height: 8))
            imageView.image = UIImage(named: "approved_rule")
        case .unedited:
            titleLabel.textColor = ColorConstants.lightText
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "dot.circle.fill") //TODO: change it with the real asset
                imageView.image = imageView.image?.resizeImage(rect: CGSize(width: 7, height: 7))
                imageView.image = imageView.image?.withTintColor(ColorConstants.lightGrayColor)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
