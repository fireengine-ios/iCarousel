//
//  WaitingForWiFiPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 14.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class WaitingForWiFiPopUp: BaseView {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var settingsButton: CircleYellowButton?
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        titleLabel?.text = TextConstants.waitingForWiFiPopUpTitle
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel?.textColor = ColorConstants.textGrayColor
        
        settingsButton?.setTitle(TextConstants.waitingForWiFiPopUpSettingsButton, for: .normal)
    }
    
    @IBAction func onSettingsButton() {
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
