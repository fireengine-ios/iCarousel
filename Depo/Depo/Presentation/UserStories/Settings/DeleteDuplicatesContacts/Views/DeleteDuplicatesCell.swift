//
//  DeleteDuplicatesCell.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class DeleteDuplicatesCell: UITableViewCell {
    
    @IBOutlet private weak var letterView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.backgroundColor = ColorConstants.photoCell
        }
    }
    
    @IBOutlet private weak var letterLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaDemFont(size: 20)
            newValue.textColor = ColorConstants.duplicatesGray
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = ColorConstants.duplicatesGray
        }
    }
    
    @IBOutlet private weak var duplicatesLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaFont(size: 12)
            newValue.textColor = ColorConstants.duplicatesGray
        }
    }
    
    func configure(with contact: ContactSync.AnalyzedContact) {
        nameLabel.text = contact.name
        duplicatesLabel.text = String(format: TextConstants.deleteDuplicatesCount, contact.numberOfErrors)
        
        let letters = contact.name.split(separator: " ").compactMap { $0.first?.uppercased() }
        letterLabel.text = letters.joined()
    }
}
