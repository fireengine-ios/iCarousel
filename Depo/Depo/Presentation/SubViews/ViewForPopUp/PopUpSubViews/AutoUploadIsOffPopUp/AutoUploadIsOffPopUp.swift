//
//  AutoUploadIsOffPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 11.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class AutoUploadIsOffPopUp: BaseView {
    
    @IBOutlet weak var titleText: UILabel?
    @IBOutlet weak var cancelButton: CircleButtonWithGrayCorner?
    @IBOutlet weak var settingsButton: CircleYellowButton?

    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleText?.text = TextConstants.autoUploaOffPopUpText
        titleText?.font = UIFont.TurkcellSaturaRegFont(size: 12)
        titleText?.textColor = ColorConstants.textGrayColor
        
        cancelButton?.setTitle(TextConstants.autoUploaOffCancel, for: .normal)
        
        settingsButton?.setTitle(TextConstants.autoUploaOffSettings, for: .normal)
    }
    
    override func viewDeletedBySwipe(){
        onCancelButton()
    }

    @IBAction func onCancelButton(){
        CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
        PopUpService.shared.resetLoginCountForUploadOffPopUp()
    }
    
    @IBAction func onSettingsButton(){
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
