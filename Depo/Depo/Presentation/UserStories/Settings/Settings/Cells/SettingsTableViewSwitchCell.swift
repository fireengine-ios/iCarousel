//
//  SettingsTableViewSwitchCell.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SettingsTableViewSwitchCell: UITableViewCell {
    
    @IBOutlet weak var cellSwitch: UISwitch!
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellLabel.textColor = ColorConstants.textGrayColor
        cellLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        //let bgView = UIView()
//        if (selected){
//            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
//            backgroundColor = ColorConstants.selectedCellBlueColor
//        }else{
//            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
//            backgroundColor = ColorConstants.whiteColor
//        }
//        //backgroundView = bgView
//        // Configure the view for the selected state
//    }
    
    func setTextForLabel(titleText: String, needShowSeparator:Bool){
        cellLabel.text = titleText
        separator.isHidden = !needShowSeparator
    }
    
}
