//
//  FreeAppSpaceFreeAppSpaceViewController.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeAppSpaceViewController: BaseFilesGreedViewController {

    @IBOutlet weak var duplicatesTextLabel: UILabel!
    
    override func viewDidLoad() {
        
        
        scrolliblePopUpView.addNotPermittedPopUpViewTypes(types: [.upload, .sync, .download, .freeAppSpace, .freeAppSpaceWarning])
        
        duplicatesTextLabel.textColor = ColorConstants.darkText
        duplicatesTextLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        duplicatesTextLabel.text = String(format: TextConstants.freeAppSpaceTitle, 5)
        
        super.viewDidLoad()
    }
    
}

