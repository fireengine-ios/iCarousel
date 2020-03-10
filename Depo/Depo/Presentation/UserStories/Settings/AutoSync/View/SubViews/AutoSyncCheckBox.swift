//
//  AutoSyncCheckBox.swift
//  Depo
//
//  Created by Andrei Novikau on 3/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AutoSyncCheckBox: UIButton {
    
    private let checkedImage = UIImage(named: "checkbox_active")
    private let uncheckedImage = UIImage(named: "checkBoxNotSelected")
    private let disabledImage = UIImage(named: "checkboxSelected")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setImage(uncheckedImage, for: .normal)
        setImage(checkedImage, for: .selected)
        setImage(disabledImage, for: [.disabled, .selected])
    }
}
