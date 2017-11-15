//
//  SwitchCell.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 14/11/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class SwitchCell: UITableViewCell {
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    func fill(with text: String) {
        titleLabel.text = text
    }
    
    func select() {
        enableSwitch.setOn(!enableSwitch.isOn, animated: true)
    }
}
