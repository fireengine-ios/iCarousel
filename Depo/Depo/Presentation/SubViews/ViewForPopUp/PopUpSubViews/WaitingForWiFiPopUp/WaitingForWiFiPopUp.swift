//
//  WaitingForWiFiPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 14.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class WaitingForWiFiPopUp: BaseView {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var syncButton: SimpleButtonWithBlueText?
    @IBOutlet weak var settingsButton: CircleYellowButton?
    
    override func configurateView(){
        super.configurateView()
        titleLabel?.text = TextConstants.waitingForWiFiPopUpTitle
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel?.textColor = ColorConstants.textGrayColor
        
        syncButton?.setTitle(TextConstants.waitingForWiFiPopUpSyncButton, for: .normal)
        
        settingsButton?.setTitle(TextConstants.waitingForWiFiPopUpSettingsButton, for: .normal)
    }
    
    @IBAction func onSyncButton(){
        
    }
    
    @IBAction func onSettingsButton(){
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
