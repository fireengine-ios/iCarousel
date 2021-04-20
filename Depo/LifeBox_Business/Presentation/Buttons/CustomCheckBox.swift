//
//  CustomCheckBox.swift
//  Depo
//
//  Created by Oleg on 12.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CustomCheckBox: UIButton {

    let checkedImage = UIImage(named: "checkboxSelected")
    let uncheckedImage = UIImage(named: "checkBoxNotSelected")
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked{
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }

}
