//
//  WaitingForWiFiPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 14.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class WaitingForWiFiPopUp: BaseCardView {

    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var settingsButton: CircleYellowButton?
    
    private let spacing: CGFloat = 2.1
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        titleLabel?.text = TextConstants.waitingForWiFiPopUpTitle
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel?.textColor = ColorConstants.textGrayColor
        
        settingsButton?.setTitle(TextConstants.waitingForWiFiPopUpSettingsButton, for: .normal)
        settingsButton?.setImage(UIImage(named: "CogForButtons"), for: .normal)
        settingsButton?.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing)
    }
    
    @IBAction private func onSettingsButton() {
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
