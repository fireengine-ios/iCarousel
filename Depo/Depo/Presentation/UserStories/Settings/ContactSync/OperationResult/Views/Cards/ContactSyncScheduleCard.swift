//
//  ContactSyncScheduleCard.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class ContactSyncScheduleCard: ContactSyncBaseCardView, NibInit {
    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBackupSuccessCardTitle
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .left
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet weak var message: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBackupSuccessCardMessage
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .left
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var syncOptionText: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBigCardAutobackupFormat
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var syncOptionButton: UIButton! {
        willSet {
            newValue.setTitle(" ", for: .normal)
            newValue.backgroundColor = .clear
        }
    }
    
    
    private var actionHandler: SenderHandler?
    
    //MARK:- Public
    
    func set(periodicSyncOption: PeriodicContactsSyncOption) {
        DispatchQueue.toMain {
            self.syncOptionText.text = String(format: TextConstants.contactSyncBigCardAutobackupFormat, periodicSyncOption.localizedText)
        }
    }
    
    @discardableResult
    func onAction(handler: @escaping SenderHandler) -> ContactSyncScheduleCard {
        actionHandler = handler
        return self
    }
    
    //MARK: - IB Actions
    
    @IBAction private func didTapSyncOptionButton(_ sender: Any) {
        actionHandler?(sender)
    }
}
