//
//  ContactBackupOld.swift
//  Depo
//
//  Created by Oleg on 23.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactBackupOld: BaseCardView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var bacupButton: UIButton!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    class func isContactInfoObjectEmpty(object: JSON?) -> Bool {
        if object?["lastBackupDate"].date != nil {
            return false
        }
        return true
    }
    
    override func configurateView() {
        super.configurateView()
        
        headerLabel?.font = .appFont(.medium, size: 16)
        headerLabel?.textColor = AppColor.label.color
        headerLabel?.text = TextConstants.homePageContactBacupHeader
        
        titleLabel?.font = .appFont(.medium, size: 14)
        titleLabel?.textColor = AppColor.label.color
        
        subTitle?.font = .appFont(.light, size: 14)
        subTitle?.textColor = AppColor.label.color
        
        bacupButton?.titleLabel?.font = .appFont(.bold, size: 14)
        bacupButton?.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
        bacupButton?.setTitle(TextConstants.homePageContactBacupButton, for: .normal)
        
        lastUpdateLabel?.font = .appFont(.light, size: 14)
        lastUpdateLabel?.textColor = AppColor.label.color
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        configurateByResponseObject()
    }
    
    func configurateByResponseObject() {
        let lastBackupDate = getLastBackupDate()
        let monthesAfterLastBacup = getMonthesAfterLastBacup()
        
        titleLabel?.text = String(format: TextConstants.homePageContactBacupOldTitle, monthesAfterLastBacup)
        subTitle?.text = String(format: TextConstants.homePageContactBacupOldSubTitle, monthesAfterLastBacup)
        
        lastUpdateLabel?.text = String(format: "%@ %@", TextConstants.homePageContactBacupLastUpate, lastBackupDate)
    }
    
    func getLastBackupDate() -> String {
        if let dateLastBackup = cardObject?.details?["lastBackupDate"].date {
           return dateLastBackup.getDateInFormat(format: "dd.MM.YYYY")
        }
        
        return ""
    }
    
    func getMonthesAfterLastBacup() -> String {
        if let dateLastBackup = cardObject?.details?["lastBackupDate"].date {
            var monthsCount = dateLastBackup.getMonthsBetweenDateAndCurrentDate()
            
            /// if the date from last backup is less than a month
            monthsCount = monthsCount == 0 ? 1 : monthsCount 
            
            return String(format: "%d", monthsCount)
        }
        return ""
    }
    
    @IBAction func onCloseButton() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .contactBacupOld)
    }
    
    @IBAction func onBackupButton() {
        let router = RouterVC()
        let controller = router.syncContacts
        router.pushViewController(viewController: controller)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 12.0
        let h = bacupButton.frame.origin.y + bacupButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
}
