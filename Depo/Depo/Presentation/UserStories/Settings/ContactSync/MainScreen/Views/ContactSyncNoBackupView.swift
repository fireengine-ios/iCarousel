//
//  ContactSyncNoBackupView.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


final class ContactSyncNoBackupView: UIView, NibInit {
    
    weak var delegate: ContactsBackupActionProviderProtocol?
    

    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 24.0)
            newValue.textColor = AppColor.marineTwoAndWhite.color
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupTitle
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 16.0)
            newValue.textColor = ColorConstants.charcoalGrey
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupMessage
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var actionButton: RoundedInsetsButton! {
        willSet {
            newValue.insets = UIEdgeInsets(topBottom: 2.0, rightLeft: 48.0)
            newValue.backgroundColor = AppColor.darkBlueAndTealish.color
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.setTitle(TextConstants.contactSyncBackupButton, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    
    //MARK: - IB Actions
    
    @IBAction private func backUp(_ sender: Any) {
        if let delegate = delegate {
            delegate.backUp(isConfirmed: true)
        }
    }
}
