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
        newValue.image = UIImage(named: "unedited_dot")
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

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
    }

    private func configureRuleStatus(with status: PasswordRuleStatus) {
        switch status {
        case .invalid:
            titleLabel.textColor = ColorConstants.invalidPasswordRule
            imageView.image = UIImage(named: "unapproved_rule")
        case .valid:
            titleLabel.textColor = ColorConstants.switcherGreenColor
            imageView.image = UIImage(named: "approved_rule")
        case .unedited:
            titleLabel.textColor = ColorConstants.lightText
            imageView.image = UIImage(named: "unedited_dot")
        }
    }
}
