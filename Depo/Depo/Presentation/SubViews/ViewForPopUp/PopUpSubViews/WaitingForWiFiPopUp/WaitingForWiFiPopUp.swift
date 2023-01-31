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
    @IBOutlet weak var settingsButton: UIButton!
    
    
    private let spacing: CGFloat = 2.1
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        titleLabel?.text = TextConstants.waitingForWiFiPopUpTitle
        titleLabel?.font = .appFont(.medium, size: 16)
        titleLabel?.textColor = AppColor.label.color
        
        settingsButton.setTitle(TextConstants.waitingForWiFiPopUpSettingsButton, for: .normal)
        settingsButton.titleLabel?.font = .appFont(.bold, size: 14)
        settingsButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
    }
    
    @IBAction func settingsButtonTap(_ sender: Any) {
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
