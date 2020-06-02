//
//  ContactBackupHistoryPopupFactory.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/2/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum ContactBackupHistoryPopupFactory {
    
    case delete
    case restore
    
    func createPopup(okHandler: @escaping PopUpButtonHandler) -> (UIViewController) {
        switch self {
        case .delete:
            return PopUpController.with(title: TextConstants.contactBackupHistoryDeletePopUpTitle, message: TextConstants.contactBackupHistoryDeletePopUpMessage, image: .delete, firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.ok, secondAction: okHandler)
        case .restore:
            return PopUpController.with(title: TextConstants.contactBackupHistoryRestorePopUpTitle, message: TextConstants.contactBackupHistoryRestorePopUpMessage, image: .restore, firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.ok, secondAction: okHandler)
        }
    }
}


