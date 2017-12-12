//
//  AutoUploadIsOffPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 11.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AutoUploadIsOffPopUp: BaseView {
    
    @IBOutlet weak var titleText: UILabel?
    @IBOutlet weak var cancelButton: CircleButtonWithGrayCorner?
    @IBOutlet weak var settingsButton: CircleYellowButton?
    
    override func configurateView(){
        super.configurateView()
        titleText?.text = TextConstants.autoUploaOffPopUpText
        titleText?.font = UIFont.TurkcellSaturaRegFont(size: 12)
        titleText?.textColor = ColorConstants.textGrayColor
        
        cancelButton?.setTitle(TextConstants.autoUploaOffCancel, for: .normal)
        
        settingsButton?.setTitle(TextConstants.autoUploaOffSettings, for: .normal)
    }
    

    @IBAction func onCancelButton(){
        WrapItemOperatonManager.default.stopOperationWithType(type: .autoUploadIsOff)
    }
    
    @IBAction func onSettingsButton(){
        let router = RouterVC()
        RouterVC().pushViewController(viewController: router.autoUpload)
    }
    
}
