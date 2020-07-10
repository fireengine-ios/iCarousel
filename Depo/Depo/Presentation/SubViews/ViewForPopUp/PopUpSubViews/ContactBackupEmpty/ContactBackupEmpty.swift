//
//  ContactBackupEmpty.swift
//  Depo
//
//  Created by Oleg on 23.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class ContactBackupEmpty: ContactBackupOld {

    override func configurateView() {
        super.configurateView()
        
        titleLabel?.text = TextConstants.homePageContactBacupEmptyTitle
        
        subTitle?.text = TextConstants.homePageContactBacupEmptySubTitle
        
        lastUpdateLabel?.text = ""
    }
    
    
    @IBAction override func onCloseButton() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .contactBacupEmpty)
    }
    
    override func configurateByResponseObject() {
        
    }

}
