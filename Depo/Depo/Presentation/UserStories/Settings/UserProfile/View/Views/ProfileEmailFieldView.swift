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

    var showsVerificationStatus: Bool = true

    weak var delegate: ProfileEmailFieldViewDelegate?

    override var isEditState: Bool {
        get { super.isEditState }
        set {
            super.isEditState = newValue
        }
    }
    
    // MARK: Private
    static let verificationViewHeight: CGFloat = 16

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
        return button
    }()

    override func initialSetup() {
        super.initialSetup()

        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none

        updateVerificationStatus()
        updateVerifyButtonStatus()
        setupLayout()
        
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
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
        addSubview(verifyButton)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        verifyButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        verifyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }

    private func updateVerificationStatus() {
        verifiedView.isHidden = !isVerified
        verifyButton.isHidden = isVerified
    }
    
    func updateVerifyButtonStatus() {
        if !isVerified {
            guard let text = textField.text else { return }
            verifyButton.isHidden = text.isEmpty
        }
    }

    @objc private func verifyTapped() {
        delegate?.profileEmailFieldViewVerifyTapped(self)
    }
}
