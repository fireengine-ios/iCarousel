//
//  PrivateShareAccessItemTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 01.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareAccessItemTableViewCellDelegate: class {
    func onRoleTapped(sender: UIButton,
                      info: PrivateShareAccessListInfo)
    func onExactRoleDecisionTapped(_ type: ElementTypes,
                                   _ info: PrivateShareAccessListInfo,
                                   _ cell: PrivateShareAccessItemTableViewCell)
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

    @IBOutlet private weak var roleButton: IndexPathButton! {
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
        if #available(iOS 14.0, *) {
            roleButton.menu = nil
        }
        roleButton.setTitle("", for: .normal)
        nameLabel.text = ""
        dateLabel.text = ""
    }

    func setup(with info: PrivateShareAccessListInfo,
               fileType: FileType,
               isRootItem: Bool,
               indexPath: IndexPath) {
        self.info = info

        if isRootItem, fileType != .folder {
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

        setupMenu(indexPath: indexPath)
    }

    @IBAction private func onRoleTapped(sender: UIButton) {
        if #available(iOS 14.0, *) {
            //use button + UIMenu
            return
        }

        triggerHapticFeedback()
        if let info = info {
            delegate?.onRoleTapped(sender: sender, info: info)
        }
    }

    @objc private func triggerHapticFeedback() {
        let lightFeedback = UIImpactFeedbackGenerator(style: .light)
        lightFeedback.impactOccurred()
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

private extension PrivateShareAccessItemTableViewCell {

    private func setupMenu(indexPath: IndexPath) {
        guard
            #available(iOS 14, *),
            let info = info
        else {
            return
        }

        roleButton.change(indexPath: indexPath)

        roleButton.showsMenuAsPrimaryAction = true
        roleButton.addTarget(self, action: #selector(triggerHapticFeedback), for: .menuActionTriggered)

        let isRoleEditor: Bool = info.role == .editor
        let isRoleViewer: Bool = info.role == .viewer
        let currentState = isRoleEditor ? ElementTypes.editorRole : isRoleViewer ? ElementTypes.viewerRole : ElementTypes.variesRole

        let menu = MenuItemsFabric.generateMenuForManagingRole(currentState: currentState) { [weak self] decision in
            guard
                let self = self,
                let info = self.info
            else {
                return
            }

            switch decision {
            case .elementType(let type):
                self.triggerHapticFeedback()
                self.delegate?.onExactRoleDecisionTapped(type, info, self)
            default:
                break
            }
        }
        roleButton.menu = menu
    }

    private func setMenu(isAvailable: Bool) {
        if isAvailable, let indexPath = roleButton.indexPath {
            setupMenu(indexPath: indexPath)
        }
    }
}
