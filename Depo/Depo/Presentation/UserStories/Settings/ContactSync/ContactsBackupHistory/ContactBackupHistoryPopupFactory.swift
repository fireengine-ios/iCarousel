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
    
    private var title: String {
        switch self {
        case .delete:
            return TextConstants.contactBackupHistoryDeletePopUpTitle
        case .restore:
            return TextConstants.contactBackupHistoryRestorePopUpTitle
        }
    }
    
    private var message: String {
        switch self {
        case .delete:
            return TextConstants.contactBackupHistoryDeletePopUpMessage
        case .restore:
            return TextConstants.contactBackupHistoryRestorePopUpMessage
        }
    }
    
    private var image: PopUpImage {
        switch self {
        case .delete, .restore:
            return .question
        }
    }
    
    func createPopup(okHandler: @escaping PopUpButtonHandler) -> (UIViewController) {
        return PopUpController.with(title: title,
                                    message: message,
                                    image: image,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    secondAction: okHandler)
    }
}


