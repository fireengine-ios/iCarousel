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

    @IBOutlet weak var stateSwitch: UISwitch!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        stateSwitch.addTarget(self, action: #selector(swichChanged), for: .touchUpInside)//valueChanged)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellGotTouched)))
    }
    
    @objc func swichChanged() {
        debugPrint("swichChanged SettingsTableViewSwitchCells")
        actionDelegate?.switchToggled(positionOn: stateSwitch.isOn, cell: self)
    }
    
    @objc func cellGotTouched() {
        stateSwitch.setOn(!stateSwitch.isOn, animated: true)
        actionDelegate?.switchToggled(positionOn: stateSwitch.isOn, cell: self)
    }
    
    func setTextForLabel(titleText: String, needShowSeparator:Bool) {
        titleLabel.text = titleText
        separator.isHidden = !needShowSeparator
    }
    
    func changeSwithcState(turnOn: Bool) {
        if stateSwitch.isOn != turnOn {
          stateSwitch.setOn(turnOn, animated: true)
        }
    }
}
