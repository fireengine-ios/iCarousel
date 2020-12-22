//
//  AutoUploadIsOffPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 11.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class AutoUploadIsOffPopUp: BaseCardView {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var settingsButton: CircleYellowButton!
    @IBOutlet weak var subTitleLabel: UILabel!

    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleText.text = TextConstants.autoUploaOffPopUpTitleText
        titleText.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleText.textColor = ColorConstants.textGrayColor
        
        subTitleLabel.text = TextConstants.autoUploaOffPopUpSubTitleText
        subTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        subTitleLabel.textColor = ColorConstants.blueColor
        
        settingsButton?.setTitle(TextConstants.autoUploaOffSettings, for: .normal)
    }
    
    override func viewDeletedBySwipe() {
        onCancel()
    }

    func onCancel() {
        CardsManager.default.stopOperationWith(type: .autoUploadIsOff)
        PopUpService.shared.resetLoginCountForUploadOffPopUp()
    }
    
    @IBAction func onSettingsButton() {
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 6.0
        let h = settingsButton.frame.origin.y + settingsButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
}
