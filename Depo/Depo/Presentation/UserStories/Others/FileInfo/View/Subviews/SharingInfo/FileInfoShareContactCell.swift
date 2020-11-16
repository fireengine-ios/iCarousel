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
    func didSelect(contact: ShareContact)
    func didTappedPlusButton()
}

final class FileInfoShareContactCell: UICollectionViewCell {
    
    @IBOutlet private weak var circleView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.frame.height * 0.5
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var button: UIButton! {
        willSet {
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
        }
    }
    
    private var type: FileInfoShareContactCellType = .contact
    private var contact: ShareContact?
    weak var delegate: FileInfoShareContactCellDelegate?
    
    func setup(type: FileInfoShareContactCellType, contact: ShareContact?, count: Int?, index: Int) {
        self.type = type
        self.contact = contact

        switch type {
        case .contact:
            button.setTitle(contact?.displayName ?? "", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
            button.backgroundColor = color(for: index)
            
        case .additionalCount:
            if let count = count {
                button.setTitle("\(count)", for: .normal)
            } else {
                button.setTitle("", for: .normal)
            }
            button.setTitleColor(ColorConstants.marineFour, for: .normal)
            button.layer.borderWidth = 2
            button.layer.borderColor = ColorConstants.marineFour.cgColor
            
        case .plusButton:
            button.setTitle("", for: .normal)
            button.setImage(UIImage(named: ""), for: .normal)
            button.layer.borderWidth = 0
        }
    }
    
    private func loadAvatar(url: URL) {
        
    }
    
    @IBAction private func onButtonTapped() {
        switch type {
        case .contact:
            if let contact = contact {
                delegate?.didSelect(contact: contact)
            }
        case .additionalCount:
            break
        case .plusButton:
            delegate?.didTappedPlusButton()
        }
    }
    
    private func color(for index: Int) -> UIColor? {
        switch index.remainderReportingOverflow(dividingBy: 6).partialValue {
        case 0:
            return .lrTealishTwo
        case 1:
            return ColorConstants.marineFour
        case 2:
            return .lrDarkSkyBlue
        case 3:
            return .lrOrange
        case 4:
            return .lrButterScotch
        case 5:
            return .lrFadedRed
        default:
            return nil
        }
    }
}
