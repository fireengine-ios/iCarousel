//
//  ContactBackupOld.swift
//  Depo
//
//  Created by Oleg on 23.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactBackupOld: BaseView {

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
        
        headerLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        headerLabel?.textColor = ColorConstants.darkText
        headerLabel?.text = TextConstants.homePageContactBacupHeader
        
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel?.textColor = ColorConstants.textGrayColor
        
        subTitle?.font = UIFont.TurkcellSaturaRegFont(size: 12)
        subTitle?.textColor = ColorConstants.textGrayColor
        
        bacupButton?.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        bacupButton?.setTitleColor(ColorConstants.blueColor, for: .normal)
        bacupButton?.setTitle(TextConstants.homePageContactBacupButton, for: .normal)
        
        lastUpdateLabel?.font = UIFont.TurkcellSaturaRegFont(size: 14)
        lastUpdateLabel?.textColor = ColorConstants.darkBorder
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
        CardsManager.default.stopOperationWithType(type: .contactBacupOld)
    }
    
    @IBAction func onBackupButton() {
        let router = RouterVC()
        let controller = router.syncContacts
        router.pushViewController(viewController: controller)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace : CGFloat = 0.0
        let h = bacupButton.frame.origin.y + bacupButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
}
