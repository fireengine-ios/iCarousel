//
//  AutoSyncCheckBox.swift
//  Depo
//
//  Created by Andrei Novikau on 3/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AutoSyncCheckBox: UIButton {
    
    private let checkedImage = Image.iconSelectCheck.image
    private let uncheckedImage = Image.iconSelectEmpty.image
    private let disabledImage = Image.iconSelectEmpty.image
    
    func setup(isSelected: Bool, isAllChecked: Bool = true) {
        let image: UIImage?
        if isSelected {
            image = isAllChecked ? checkedImage : disabledImage
        } else {
            image = uncheckedImage
        }
        setImage(image, for: .normal)
    }
}
