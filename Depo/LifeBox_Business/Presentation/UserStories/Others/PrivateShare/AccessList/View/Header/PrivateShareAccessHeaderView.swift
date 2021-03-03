//
//  PrivateShareAccessHeaderView.swift
//  Depo
//
//  Created by Anton Ignatovich on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class PrivateShareAccessHeaderView: UIView {
    private struct Constants {
        static let stackViewEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 30, left: 20, bottom: 15, right: 20)
        static let emailToLabelVerticalOffset: CGFloat = 5
    }

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        label.textColor = ColorConstants.infoPageValueText
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        label.textColor = ColorConstants.sharedContactTitleSubtitle
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.emailToLabelVerticalOffset
        stack.backgroundColor = .clear
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(stackView)
        stackView.pinToSuperviewEdges(offset: Constants.stackViewEdgeInsets)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
    }

    func updateTexts(name: String?, email: String?) {
        nameLabel.text = name
        emailLabel.text = email
    }
}
