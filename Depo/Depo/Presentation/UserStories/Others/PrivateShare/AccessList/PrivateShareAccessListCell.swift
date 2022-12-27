//
//  PrivateShareAccessListCell.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareAccessListCellDelegate: AnyObject {
    func onRoleTapped(sender: UIButton, info: PrivateShareAccessListInfo)
}

final class PrivateShareAccessListCell: UITableViewCell {

    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var roleButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.filesLabel.color, for: .normal)
            newValue.titleLabel?.font = .appFont(.regular, size: 14)
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
        }
    }
    
    private var info: PrivateShareAccessListInfo?
    weak var delegate: PrivateShareAccessListCellDelegate?
    
    func setup(with info: PrivateShareAccessListInfo, fileType: FileType, isRootItem: Bool) {
        self.info = info
        
        if isRootItem {
            nameLabel.text = info.object.name
        } else {
            nameLabel.text = String(format: TextConstants.privateShareAccessFromFolder, info.object.name)
        }
        typeImageView.image = WrapperedItemUtil.privateSharePlaceholderImage(fileType: fileType)
        
        if let expirationDate = info.expirationDate {
            let dateString = expirationDate.getDateInFormat(format: "dd MMMM yyyy")
            dateLabel.text = String(format: TextConstants.privateShareAccessExpiresDate, dateString)
        } else {
            dateLabel.text = ""
        }
        
        roleButton.setTitle(info.role.accessListTitle, for: .normal)
        
        switch info.role {
        case .owner:
            roleButton.setImage(nil, for: .normal)
            roleButton.isUserInteractionEnabled = false
        case .viewer, .editor, .varying:
            roleButton.setImage(Image.iconArrowDownSmall.image, for: .normal)
            roleButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction private func onRoleTapped(sender: UIButton) {
        if let info = info {
            delegate?.onRoleTapped(sender: sender, info: info)
        }
    }
}
