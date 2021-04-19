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

protocol FileInfoShareContactCellDelegate: class {
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
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 15)
            newValue.titleLabel?.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var roleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.infoPageValueText
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.textAlignment = .center
            newValue.adjustsFontSizeToFitWidth = true
            newValue.minimumScaleFactor = 0.7
        }
    }
    
    private var type: FileInfoShareContactCellType = .contact
    private var contact: SharedContact?
    weak var delegate: FileInfoShareContactCellDelegate?
    private let imageDownloder = ImageDownloder()
    
    //MARK: -

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ColorConstants.tableBackground
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.backgroundColor = ColorConstants.tableBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        button.backgroundColor = .clear
        circleView.layer.borderWidth = 0
        roleLabel.text = ""
        button.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 14)
        button.titleEdgeInsets = .zero
    }
    
    func setup(type: FileInfoShareContactCellType,
               contact: SharedContact?,
               count: Int?,
               index: Int) {
        self.type = type
        self.contact = contact

        switch type {
        case .contact:
            button.titleEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
            if let initials = contact?.initials, !initials.isEmpty {
                button.setTitle(initials, for: .normal)
            }
            button.backgroundColor = circleBackgroundColor(for: index)
            
            button.setTitleColor(onCircleTextColor(for: index), for: .normal)
            roleLabel.text = contact?.role.infoMenuTitle
            
        case .additionalCount:
            if let count = count {
                if count < 1000 {
                    button.setTitle("+ \(count)", for: .normal)
                } else {
                    button.setTitle("+ \(count / 1000)k", for: .normal)
                }
            }

            if let count = count, count > 99, count < 1000 {
                button.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 12)
            }
            
            button.setTitleColor(ColorConstants.infoPagePlusButtonText, for: .normal)
            circleView.layer.borderWidth = 1
            circleView.layer.borderColor = ColorConstants.infoPagePlusButtonText.cgColor
            
        case .plusButton:
            button.setImage(UIImage(named: "plusFillButton"), for: .normal)
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

extension FileInfoShareContactCell {
    private func circleBackgroundColor(for index: Int) -> UIColor? {
        switch index {
        case 0, 3:
            return ColorConstants.infoPageContactDarkBackground
        case 1, 2:
            return ColorConstants.infoPageContactLigherBackground
        default:
            return nil
        }
    }

    private func onCircleTextColor(for index: Int) -> UIColor? {
        switch index {
        case 0, 3:
            return ColorConstants.infoPageDarkerNickname
        case 1, 2:
            return ColorConstants.infoPageLigherNickname
        default:
            return nil
        }
    }
}
