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
    @IBOutlet weak var settingsButton: CircleYellowButton?

    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleText?.text = TextConstants.autoUploaOffPopUpText
        titleText?.font = UIFont.TurkcellSaturaRegFont(size: 14)
        titleText?.textColor = ColorConstants.textGrayColor
        
        settingsButton?.setTitle(TextConstants.autoUploaOffSettings, for: .normal)
    }
    
    override func viewDeletedBySwipe(){
        onCancel()
    }

    func onCancel(){
        CardsManager.default.stopOperationWithType(type: .autoUploadIsOff)
        PopUpService.shared.resetLoginCountForUploadOffPopUp()
    }
    
    @IBAction func onSettingsButton(){
        let router = RouterVC()
        router.pushViewController(viewController: router.autoUpload)
    }
    
}
