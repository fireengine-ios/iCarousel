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
    
    // MARK: Private
    static let verificationViewHeight: CGFloat = 16

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
        let button = UIButton(type: .system)
        button.setTitle(localized(.profileVerifyButtonTitle), for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.titleLabel?.font = .appFont(.regular, size: 14.0)
        button.contentEdgeInsets = UIEdgeInsets(topBottom: 0, rightLeft: 10)
        button.backgroundColor = AppColor.profileInfoOrange.color
        button.layer.cornerRadius = ProfileEmailFieldView.verificationViewHeight
        button.addTarget(ProfileEmailFieldView.self, action: #selector(verifyTapped), for: .touchUpInside)
        return button
    }()

    override func initialSetup() {
        super.initialSetup()

        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        updateVerificationStatus()
        updateVerificationVisibility()
        setupLayout()
    }
    
    private func setupLayout() {
        verifiedViewLayout()
        verifyButtonLayout()
    }
    
    private func verifiedViewLayout() {
        textField.addSubview(verifiedView)
        verifiedView.translatesAutoresizingMaskIntoConstraints = false
        verifiedView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 10).isActive = true
        verifiedView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: -10).isActive = true
        verifiedView.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -20).isActive = true
    }
    
    private func verifyButtonLayout() {
        textField.addSubview(verifyButton)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.topAnchor.constraint(equalTo: textField.topAnchor, constant: 10).isActive = true
        verifyButton.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: -10).isActive = true
        verifyButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -20).isActive = true
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
