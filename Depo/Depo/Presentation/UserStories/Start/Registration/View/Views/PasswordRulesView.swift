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
        newValue.image = UIImage(named: "approved_rule")
        newValue.contentMode = .scaleAspectFit
        return newValue
    }()

    let titleLabel: UILabel = {
        let newValue = UILabel()
        newValue.textColor = ColorConstants.lightText
        newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
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

    func setupStackView() {
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let edgeInset: CGFloat = 0
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInset).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edgeInset).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edgeInset).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true

        /// why it is not working instead of constraints???
        //stackView.frame = bounds
        //stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //stackView.translatesAutoresizingMaskIntoConstraints = true

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
    }

    func configureRuleStatus(with status: PasswordRuleStatus) {
        switch status {
        case .invalid:
            titleLabel.textColor = ColorConstants.invalidPasswordRule
            imageView.image = UIImage(named: "spotify_cross")
            imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        case .valid:
            titleLabel.textColor = ColorConstants.switcherGreenColor
            imageView.image = UIImage(named: "approved_rule")
            imageView.frame = CGRect(x: 0, y: 0, width: 8, height: 11)
        case .unedited:
            titleLabel.textColor = ColorConstants.lightText
            imageView.image = UIImage(named: "")
        }
    }
}
