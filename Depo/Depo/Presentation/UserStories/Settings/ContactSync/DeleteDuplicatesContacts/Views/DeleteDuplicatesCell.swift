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
            newValue.backgroundColor = AppColor.grayMain.color
        }
    }
    
    @IBOutlet private weak var letterLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.medium, size: 14.4)
            newValue.textColor = AppColor.darkBlue.color
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var duplicatesLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .appFont(.light, size: 14.0)
            newValue.textColor = AppColor.label.color
        }
    }
    
    func configure(with contact: ContactSync.AnalyzedContact) {
        nameLabel.text = contact.name
        duplicatesLabel.text = String(format: TextConstants.deleteDuplicatesCount, contact.numberOfErrors)
        letterLabel.text = contact.name.first?.uppercased() ?? ""
    }
}
