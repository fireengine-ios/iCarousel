//
//  ContactBackupOld.swift
//  Depo
//
//  Created by Oleg on 23.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class ContactBackupOld: BaseView {

    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subTitle: UILabel?
    @IBOutlet weak var bacupButton: UIButton?
    @IBOutlet weak var lastUpdateLabel: UILabel?
    
    
    override func configurateView(){
        super.configurateView()
        headerLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        headerLabel?.textColor = ColorConstants.darkText
        headerLabel?.text = TextConstants.homePageContactBacupHeader
        
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel?.textColor = ColorConstants.textGrayColor
        titleLabel?.text = TextConstants.homePageContactBacupTitle
        
        subTitle?.font = UIFont.TurkcellSaturaRegFont(size: 12)
        subTitle?.textColor = ColorConstants.textGrayColor
        subTitle?.text = TextConstants.homePageContactBacupSubTitle
        
        bacupButton?.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        bacupButton?.setTitleColor(ColorConstants.blueColor, for: .normal)
        bacupButton?.setTitle(TextConstants.homePageContactBacupButton, for: .normal)
        
        lastUpdateLabel?.font = UIFont.TurkcellSaturaRegFont(size: 14)
        lastUpdateLabel?.textColor = ColorConstants.darkBorder
        lastUpdateLabel?.text = TextConstants.homePageContactBacupLastUpate

    }
    
    
    @IBAction func onCloseButton(){
        
    }
    
    @IBAction func onBackupButton(){
        
    }
    
}
