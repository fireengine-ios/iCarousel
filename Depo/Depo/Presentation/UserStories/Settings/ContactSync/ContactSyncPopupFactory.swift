//
//  ContactSyncPopupFactory.swift
//  Depo
//
//  Created by Andrei Novikau on 6/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum ContactSyncPopupType {
    case backup
    case deleteAllContacts
    case deleteBackup
    case deleteDuplicates
    case restoreBackup
    case restoreContacts
    case premium
    
    fileprivate var title: String {
        switch self {
        case .backup:
            return TextConstants.backUpContactsConfirmTitle
        case .deleteAllContacts:
            return TextConstants.deleteContactsConfirmTitle
        case .deleteBackup:
            return TextConstants.contactBackupHistoryDeletePopUpTitle
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesConfirmTitle
        case .restoreBackup:
            return TextConstants.contactBackupHistoryRestorePopUpTitle
        case .restoreContacts:
            return TextConstants.restoreContactsConfirmTitle
        case .premium:
            return TextConstants.contactSyncConfirmPremiumPopupTitle
        }
    }

    fileprivate var message: String {
        switch self {
        case .backup:
            return TextConstants.backUpContactsConfirmMessage
        case .deleteAllContacts:
            return TextConstants.deleteContactsConfirmMessage
        case .deleteBackup:
            return TextConstants.contactBackupHistoryDeletePopUpMessage
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesConfirmMessage
        case .restoreBackup:
            return TextConstants.contactBackupHistoryRestorePopUpMessage
        case .restoreContacts:
            return TextConstants.restoreContactsConfirmMessage
        case .premium:
            return TextConstants.contactSyncConfirmPremiumPopupText
        }
    }
    
    fileprivate var image: PopUpImage {
        switch self {
        case .premium:
            return .none
        default:
            return .question
        }
    }
}


final class ContactSyncPopupFactory {
    
    static func createPopup(type: ContactSyncPopupType, handler: @escaping PopUpButtonHandler) -> UIViewController {
        return PopUpController.with(title: type.title,
                                    message: type.message,
                                    image: type.image,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    secondAction: handler)
    }
    
    static func openPopUp(type: ContactSyncPopupType, handler: @escaping PopUpButtonHandler) {
        let popUp = PopUpController.with(title: type.title,
                                 message: type.message,
                                 image: type.image,
                                 firstButtonTitle: TextConstants.cancel,
                                 secondButtonTitle: TextConstants.ok,
                                 secondAction: handler)
        popUp.open()
    }
}
