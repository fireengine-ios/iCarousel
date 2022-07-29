//
//  ProfileEmailFieldView.swift
//  Depo
//
//  Created by Hady on 9/6/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol ProfileEmailFieldViewDelegate: AnyObject {
    func profileEmailFieldViewVerifyTapped(_ fieldView: ProfileEmailFieldView)
}

final class ProfileEmailFieldView: ProfileTextEnterView {
    var isVerified: Bool = false {
        didSet {
            updateVerificationStatus()
        }
    }

    var showsVerificationStatus: Bool = true {
        didSet {
            updateVerificationVisibility()
        }
    }

    weak var delegate: ProfileEmailFieldViewDelegate?

    override var isEditState: Bool {
        get { super.isEditState }
        set {
            super.isEditState = newValue
            updateVerificationVisibility()
        }
    }

    override func initialSetup() {
        super.initialSetup()

        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)

        configureVerificationContainer()
        updateVerificationStatus()
        updateVerificationVisibility()
    }

    // MARK: Private

    static let verificationViewHeight: CGFloat = 15

    private let verificationView: UIStackView = {
        let view = UIStackView()
        view.heightAnchor.constraint(equalToConstant: ProfileEmailFieldView.verificationViewHeight).isActive = true
        return view
    }()

    private let verifiedView: UIView = {
        let verifiedColor = ColorConstants.switcherGreenColor

        let label = UILabel()
        label.text = localized(.profileMailVerified)
        label.textColor = verifiedColor
        label.font = .appFont(.medium, size: 12.0)

        let icon = UIImageView(image: UIImage(named: "checkmark"))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = verifiedColor
        icon.backgroundColor = AppColor.primaryBackground.color

        let stackView = UIStackView(arrangedSubviews: [icon,label])
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()

    private let verifyButton: UIButton = {
        let button = UIButton()
        button.setTitle(localized(.profileVerifyButtonTitle), for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.titleLabel?.font = .appFont(.regular, size: 14.0)
        button.contentEdgeInsets = UIEdgeInsets(topBottom: 0, rightLeft: 10)
        button.backgroundColor = AppColor.primaryBackground.color
        button.layer.cornerRadius = ProfileEmailFieldView.verificationViewHeight / 2
        return button
    }()

    private func configureVerificationContainer() {
        verificationView.addArrangedSubview(verifiedView)
        verificationView.addArrangedSubview(verifyButton)

        let textFieldStackView = UIStackView(arrangedSubviews: [textField, verificationView])
        textFieldStackView.axis = .horizontal
        textFieldStackView.spacing = 0
        textFieldStackView.alignment = .center
        stackView.removeArrangedSubview(textField) // added in superview (ProfileTextEnterView)
        stackView.addArrangedSubview(textFieldStackView)

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func updateVerificationVisibility() {
        verificationView.isHidden = !showsVerificationStatus || isEditState
    }

    private func updateVerificationStatus() {
        verifiedView.isHidden = !isVerified
        verifyButton.isHidden = isVerified
    }

    @objc private func verifyTapped() {
        delegate?.profileEmailFieldViewVerifyTapped(self)
    }
}
