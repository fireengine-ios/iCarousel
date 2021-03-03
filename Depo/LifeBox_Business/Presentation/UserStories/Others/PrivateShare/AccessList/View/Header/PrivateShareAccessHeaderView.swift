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
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        lbl.textColor = ColorConstants.infoPageValueText
        return lbl
    }()

    private lazy var emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        lbl.textColor = ColorConstants.sharedContactTitleSubtitle
        return lbl
    }()

    private lazy var stackView: UIStackView = {
        let stk = UIStackView()
        stk.translatesAutoresizingMaskIntoConstraints = false
        stk.axis = .vertical
        stk.spacing = Constants.emailToLabelVerticalOffset
        stk.backgroundColor = .clear
        return stk
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
