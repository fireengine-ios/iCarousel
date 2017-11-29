//
//  SettingsTableViewSwitchCell.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsTableViewSwitchCellDelegate: class {
    func switchToggled(positionOn: Bool, cell: SettingsTableViewSwitchCell)
}

class SettingsTableViewSwitchCell: UITableViewCell {
    
    weak var actionDelegate: SettingsTableViewSwitchCellDelegate?
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    //TODO: create a protocol for settings cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellLabel.textColor = ColorConstants.textGrayColor
        cellLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        cellSwitch.addTarget(self, action: #selector(self.swichChanged), for: .valueChanged)
    }
    
    @objc func swichChanged() {
        actionDelegate?.switchToggled(positionOn: cellSwitch.isOn, cell: self)
    }
    
    func setTextForLabel(titleText: String, needShowSeparator:Bool) {
        cellLabel.text = titleText
        separator.isHidden = !needShowSeparator
    }
    
    func changeSwithcState(turnOn: Bool) {
        if cellSwitch.isOn != turnOn {
          cellSwitch.setOn(turnOn, animated: true)
        }
    }
}
