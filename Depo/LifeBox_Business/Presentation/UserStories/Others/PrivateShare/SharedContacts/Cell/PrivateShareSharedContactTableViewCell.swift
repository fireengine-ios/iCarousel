//
//  PrivateShareSharedContactTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareSharedContactTableViewCell: UITableViewCell {

    @IBOutlet private weak var stackViewTrailingToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackViewTrailingToImageViewConstraint: NSLayoutConstraint!

    @IBOutlet private weak var arrowImageView: UIImageView!

    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.separator
        }
    }

    @IBOutlet private weak var circleContainerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = newValue.bounds.size.height / 2.0
            newValue.backgroundColor = ColorConstants.sharedContactCircleBackground
        }
    }

    @IBOutlet private weak var initialsLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 15)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }

    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.sharedContactTitleSubtitle
        }
    }

    @IBOutlet private weak var emailLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 11)
            newValue.textColor = ColorConstants.sharedContactTitleSubtitle
        }
    }

    @IBOutlet private weak var roleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 15)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = ColorConstants.tableBackground
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.backgroundColor = ColorConstants.tableBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        roleLabel.text = ""
        emailLabel.text = ""
        nameLabel.text = ""
        initialsLabel.text = ""
        arrowImageView.isHidden = true
        stackViewTrailingToSuperviewConstraint.priority = .defaultHigh
        stackViewTrailingToImageViewConstraint.priority = .defaultLow
        roleLabel.textColor = ColorConstants.Text.labelTitle
    }

    func setup(with contact: SharedContact,
               hasPermissionToEditRole: Bool,
               isFirstCell: Bool = false) {
        arrowImageView.isHidden = !hasPermissionToEditRole
        stackViewTrailingToSuperviewConstraint.priority = hasPermissionToEditRole ? .defaultLow : .defaultHigh
        stackViewTrailingToImageViewConstraint.priority = hasPermissionToEditRole ? .defaultHigh : .defaultLow

        roleLabel.text = contact.role.infoMenuTitle
        roleLabel.textColor = hasPermissionToEditRole ? ColorConstants.Text.labelTitle : ColorConstants.sharedContactRoleDisabled
        if !contact.initials.isEmpty {
            initialsLabel.text = contact.initials
        }
        nameLabel.text = contact.displayName
        emailLabel.text = contact.subject?.email
        separatorView.isHidden = isFirstCell
    }
}
