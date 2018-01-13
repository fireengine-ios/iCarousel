//
//  DuplicatedContactTableViewCell.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var numberOfErrorsLabel: UILabel!
    
    func configure(with contact: ContactSync.AnalyzedContact) {
        nameLabel.text = contact.name
        numberOfErrorsLabel.text = String(format: TextConstants.settingsBackUpNumberOfDuplicated, contact.numberOfErrors)
    }
    
}
