//
//  PrivateShareAccessListCell.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareAccessListCellDelegate: class {
    func onRoleTapped(sender: UIButton, info: PrivateShareAccessListInfo)
}

final class PrivateShareAccessListCell: UITableViewCell {

    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.lightText
        }
    }
    
    @IBOutlet private weak var roleButton: UIButton! {
        willSet {
            newValue.setTitleColor(.lrTealishFour, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
            newValue.tintColor = .lrTealishFour
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
        }
    }
    
    private var info: PrivateShareAccessListInfo?
    weak var delegate: PrivateShareAccessListCellDelegate?
    
    func setup(with info: PrivateShareAccessListInfo) {
        self.info = info
        switch info.object.type {
        case .file:
            nameLabel.text = info.object.name
//            typeImageView.image =
        default:
            //for folders
            nameLabel.text = String(format: TextConstants.privateShareAccessFromFolder, info.object.name)
//            typeImageView.image =
        }
        
        let dateString = info.expirationDate.getDateInFormat(format: "dd MMMM yyyy")
        dateLabel.text = String(format: TextConstants.privateShareAccessExpiresDate, dateString)
        roleButton.setTitle(info.role.title, for: .normal)
    }
    
    @IBAction private func onRoleTapped(sender: UIButton) {
        if let info = info {
            delegate?.onRoleTapped(sender: sender, info: info)
        }
    }
}
