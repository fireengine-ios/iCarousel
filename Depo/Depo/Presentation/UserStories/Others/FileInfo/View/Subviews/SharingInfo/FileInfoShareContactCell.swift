//
//  FileInfoShareContactCell.swift
//  Depo
//
//  Created by Andrei Novikau on 11/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum FileInfoShareContactCellType {
    case contact
    case additionalCount
    case plusButton
}

protocol FileInfoShareContactCellDelegate: AnyObject {
    func didSelect(contact: SharedContact)
    func didTappedPlusButton()
    func didTappedOnShowAllContacts()
}

final class FileInfoShareContactCell: UICollectionViewCell {
    
    @IBOutlet private weak var circleView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet private weak var button: UIButton! {
        willSet {
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
            newValue.titleLabel?.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var roleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.filesLabel.color
            newValue.font = .appFont(.medium, size: 14)
            newValue.textAlignment = .center
            newValue.adjustsFontSizeToFitWidth = true
            newValue.minimumScaleFactor = 0.5
        }
    }
    
    private var type: FileInfoShareContactCellType = .contact
    private var contact: SharedContact?
    weak var delegate: FileInfoShareContactCellDelegate?
    private let imageDownloder = ImageDownloder()
    
    //MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        button.backgroundColor = .clear
        circleView.layer.borderWidth = 0
        roleLabel.text = ""
    }
    
    func setup(type: FileInfoShareContactCellType, contact: SharedContact?, count: Int?, index: Int) {
        self.type = type
        self.contact = contact

        switch type {
        case .contact:
            
            func setupInitials() {
                if let initials = contact?.initials, !initials.isEmpty {
                    button.setTitle(initials, for: .normal)
                    button.backgroundColor = AppColor.filesSeperator.color
                } else {
                    button.setImage(Image.iconProfileCircle.image, for: .normal)
                }
            }
            
            if let url = contact?.subject?.picture?.byTrimmingQuery {
                button.setImage(Image.iconProfileCircle.image, for: .normal)
                imageDownloder.getImageByTrimming(url: url) { [weak self] image in
                    if image == nil {
                        setupInitials()
                    } else {
                        self?.button.setImage(image, for: .normal)
                    }
                }
            } else {
                setupInitials()
            }
            
            button.setTitleColor(AppColor.filesLabel.color, for: .normal)
            roleLabel.text = contact?.role.infoMenuTitle ?? ""
            
        case .additionalCount:
            if let count = count {
                button.setTitle("+\(count)", for: .normal)
            }
            
            button.setTitleColor(ColorConstants.marineFour, for: .normal)
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = ColorConstants.marineFour.cgColor
            
        case .plusButton:
            button.setImage(Image.iconAddUnselect.image, for: .normal)
        }
    }
    
    @IBAction private func onButtonTapped() {
        switch type {
        case .contact:
            if let contact = contact {
                delegate?.didSelect(contact: contact)
            }
        case .additionalCount:
            delegate?.didTappedOnShowAllContacts()
        case .plusButton:
            delegate?.didTappedPlusButton()
        }
    }
}
