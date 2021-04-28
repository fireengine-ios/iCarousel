//
//  PrivateShareContactCell.swift
//  Depo
//
//  Created by Andrei Novikau on 11/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareContactCellDelegate: class {
    func onRoleTapped(index: Int)
}

final class PrivateShareContactCell: UITableViewCell {

    @IBOutlet private weak var avatarImageView: UIImageView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet private weak var initialsLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaDemFont(size: 18)
            newValue.textColor = .white
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var usernameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .black
        }
    }
    
    @IBOutlet private weak var roleButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -10
        }
    }
    
    private var index = 0
    weak var delegate: PrivateShareContactCellDelegate?
    
    private let imageDownloder = ImageDownloder()
    
    //MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        initialsLabel.text = ""
        nameLabel.text = ""
        usernameLabel.text = ""
    }
    
    func setup(with contact: SharedContact, index: Int) {
        self.index = index
        nameLabel.text = contact.subject?.name
        usernameLabel.text = contact.subject?.username
        
        func setupInitials() {
            if contact.initials.isEmpty {
                avatarImageView.image = UIImage(named: "contact_placeholder")
            } else {
                initialsLabel.text = contact.initials
                avatarImageView.backgroundColor = contact.color(for: index)
            }
        }
        
        if let url = contact.subject?.picture?.byTrimmingQuery {
            avatarImageView.image = UIImage(named: "contact_placeholder")
            imageDownloder.getImageByTrimming(url: url) { [weak self] image in
                if image == nil {
                    setupInitials()
                } else {
                    self?.avatarImageView.image = image
                }
            }
        } else {
            setupInitials()
        }
        
        roleButton.setTitle(contact.role.whoHasAccessTitle, for: .normal)
        switch contact.role {
        case .owner:
            roleButton.setImage(nil, for: .normal)
            roleButton.tintColor = .lrGreyish
            roleButton.isUserInteractionEnabled = false
        case .editor, .viewer, .varying:
            roleButton.setTitleColor(.lrTealishFour, for: .normal)
            roleButton.tintColor = .lrTealishFour
            roleButton.setImage(UIImage(named: "arrow_right"), for: .normal)
            roleButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction private func onRoleTapped() {
        delegate?.onRoleTapped(index: index)
    }
}
