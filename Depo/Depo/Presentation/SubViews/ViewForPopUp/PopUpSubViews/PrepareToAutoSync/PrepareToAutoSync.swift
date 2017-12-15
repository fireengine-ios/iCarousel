//
//  PrepareToAutoSync.swift
//  Depo_LifeTech
//
//  Created by Oleg on 12.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrepareToAutoSync: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override class func initFromNib() -> PrepareToAutoSync{
        if let view = super.initFromNib() as? PrepareToAutoSync{
            return view
        }
        return PrepareToAutoSync()
    }
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.text = TextConstants.prepareToAutoSunc
        
    }

}
