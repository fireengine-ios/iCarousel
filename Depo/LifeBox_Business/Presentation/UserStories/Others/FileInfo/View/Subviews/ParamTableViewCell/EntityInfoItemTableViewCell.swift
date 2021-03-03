//
//  EntityInfoItemTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class EntityInfoItemTableViewCell: UITableViewCell {

    private struct Constants {
        static let leadingTrailingOffset: CGFloat = 20
        static let topLabelToTopOffset: CGFloat = 0
        static let topLabelToBottomLabelOffset: CGFloat = 6
        static let bottomLabelToBottomOffset: CGFloat = 15
    }

    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.GTAmericaStandardRegularFont(size: 12)
        label.textColor = ColorConstants.infoPageItemTopText
        return label
    }()

    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        label.textColor = ColorConstants.infoPageItemBottomText
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.backgroundColor = ColorConstants.tableBackground
        contentView.addSubview(topLabel)
        contentView.addSubview(bottomLabel)

        topLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topLabelToTopOffset).activate()
        topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingTrailingOffset).activate()
        topLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leadingTrailingOffset).activate()
        topLabel.bottomAnchor.constraint(equalTo: bottomLabel.topAnchor, constant: -Constants.topLabelToBottomLabelOffset).activate()
        bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingTrailingOffset).activate()
        bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leadingTrailingOffset).activate()
        bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomLabelToBottomOffset).activate()
        
        topLabel.heightAnchor.constraint(equalToConstant: 14).activate()
        bottomLabel.heightAnchor.constraint(equalToConstant: 17).activate()
    }

    func setup(with topLabelText: String, and bottomLabelText: String) {
        topLabel.text = topLabelText
        bottomLabel.text = bottomLabelText
    }
}
