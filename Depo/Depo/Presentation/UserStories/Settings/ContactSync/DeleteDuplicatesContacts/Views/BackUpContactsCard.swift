//
//  BackUpContactsCard.swift
//  Depo
//
//  Created by Andrei Novikau on 5/26/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class BackUpContactsCard: ContactSyncBaseCardView, NibInit {
        
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.deleteDuplicatesBackUpTitle
//            newValue.textColor = AppColor.navyAndWhite.color
//            newValue.font = .appFont(.regular, size: 18.0)
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 16.0)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.deleteDuplicatesBackUpMessage
//            newValue.textColor = .lrBrownishGrey
//            newValue.font = .appFont(.regular, size: 14.0)
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var backupButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesBackUpButton, for: .normal)
//            newValue.setTitleColor(.lrTealishTwo, for: .normal)
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 14.0)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    var backUpHandler: VoidHandler?
    
    //MARK: - Actions

    @IBAction private func backUpNow(_ sender: UIButton) {
        backUpHandler?()
    }
}
