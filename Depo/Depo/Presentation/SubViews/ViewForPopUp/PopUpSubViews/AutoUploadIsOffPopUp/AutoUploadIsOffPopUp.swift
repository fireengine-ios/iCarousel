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
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var settingsButton: UIButton! {
        willSet {
            newValue.contentHorizontalAlignment = .left
            newValue.sizeToFit()
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
        }
    }
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleText.text = TextConstants.autoUploaOffPopUpTitleText
        titleText.font = .appFont(.medium, size: 16)
        titleText.textColor = AppColor.label.color
        
        line.backgroundColor = AppColor.discoverCardLine.color
        
        subTitleLabel.text = TextConstants.autoUploaOffPopUpSubTitleText
        subTitleLabel.font = .appFont(.medium, size: 16)
        subTitleLabel.textColor = AppColor.label.color
        subTitleLabel.numberOfLines = 2
        
        settingsButton.setTitle(TextConstants.autoUploaOffSettings, for: .normal)
        settingsButton.titleLabel?.font = .appFont(.bold, size: 22)
        settingsButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
        
    }
    
    override func viewDeletedBySwipe() {
        onCancel()
    }

    func onCancel() {
        CardsManager.default.stopOperationWith(type: .autoUploadIsOff)
        PopUpService.shared.resetLoginCountForUploadOffPopUp()
    }
    
    @IBAction func onSettingsButton(_ sender: Any) {
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
