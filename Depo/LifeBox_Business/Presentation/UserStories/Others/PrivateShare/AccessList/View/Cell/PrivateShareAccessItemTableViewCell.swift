//
//  PrivateShareAccessItemTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareAccessItemTableViewCellDelegate: class {
    func onRoleTapped(sender: UIButton, info: PrivateShareAccessListInfo)
}

final class PrivateShareAccessItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var typeImageView: UIImageView! {
        willSet {
            newValue.tintColor = ColorConstants.accessListItemName
        }
    }

    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.infoPageSeparator
        }
    }

    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.accessListItemName
        }
    }

    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 10)
            newValue.textColor = ColorConstants.accessListItemExpireDate
        }
    }

    @IBOutlet private weak var roleButton: UIButton! {
        willSet {
            newValue.setTitleColor(ColorConstants.infoPageValueText, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.tintColor = ColorConstants.infoPageValueText
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -8
        }
    }

    private var info: PrivateShareAccessListInfo?
    weak var delegate: PrivateShareAccessItemTableViewCellDelegate?

    func setup(with info: PrivateShareAccessListInfo, fileType: FileType, isRootItem: Bool) {
        self.info = info

        if isRootItem {
            nameLabel.text = info.object.name
        } else {
            nameLabel.text = String(format: TextConstants.accessPageFromFolder, info.object.name)
        }
        typeImageView.image = WrapperedItemUtil.privateSharePlaceholderImage(fileType: fileType)
        typeImageView.image = typeImageView.image?.withRenderingMode(.alwaysTemplate)

        if let expirationDate = info.expirationDate {
            let dateString = expirationDate.getDateInFormat(format: "dd MMMM yyyy")
            dateLabel.text = String(format: TextConstants.privateShareAccessExpiresDate, dateString)
        } else {
            dateLabel.text = ""
        }

        roleButton.setTitle(roleTitle(for: info.role), for: .normal)

        switch info.role {
        case .owner:
            roleButton.setImage(nil, for: .normal)
            roleButton.isUserInteractionEnabled = false
        case .viewer, .editor, .varying:
            roleButton.setImage(UIImage(named: "access_list_arrow_down"), for: .normal)
            roleButton.isUserInteractionEnabled = true
        }
    }

    @IBAction private func onRoleTapped(sender: UIButton) {
        if let info = info {
            delegate?.onRoleTapped(sender: sender, info: info)
        }
    }
}

private extension PrivateShareAccessItemTableViewCell {
    func roleTitle(for role: PrivateShareUserRole) -> String {
        switch role {
        case .editor:
            return TextConstants.accessPageRoleEditor
        case .viewer:
            return TextConstants.accessPageRoleViewer
        case .varying:
            return TextConstants.accessPageRoleVaries
        case .owner:
            return ""
        }
    }
}
