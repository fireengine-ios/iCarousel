//
//  SimpleButtonWithBlueText.swift
//  Depo
//
//  Created by Oleg on 27.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SimpleButtonWithBlueText: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(ColorConstants.blueColor, for: .normal)
        titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
    }

}
