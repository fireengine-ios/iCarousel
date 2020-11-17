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
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
            newValue.titleLabel?.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var roleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = .lrGreyishBrownThree
            newValue.font = .TurkcellSaturaRegFont(size: 14)
            newValue.textAlignment = .center
        }
    }
    
    private var type: FileInfoShareContactCellType = .contact
    private var contact: SharedContact?
    weak var delegate: FileInfoShareContactCellDelegate?
    
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
            if let initials = contact?.initials, !initials.isEmpty {
                button.setTitle(initials, for: .normal)
                button.backgroundColor = contact?.color(for: index) ?? .clear
            } else {
                button.setImage(UIImage(named: "contact_placeholder"), for: .normal)
            }
            
            button.setTitleColor(.white, for: .normal)
            roleLabel.text = contact?.role.infoMenuTitle ?? ""
            
        case .additionalCount:
            if let count = count {
                button.setTitle("+\(count)", for: .normal)
            }
            
            button.setTitleColor(ColorConstants.marineFour, for: .normal)
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = ColorConstants.marineFour.cgColor
            
        case .plusButton:
            button.setImage(UIImage(named: "plus_large"), for: .normal)
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
