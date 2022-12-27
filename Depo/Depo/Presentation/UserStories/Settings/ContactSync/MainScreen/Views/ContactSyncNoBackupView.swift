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
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.lightGray.cgColor
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = CGSize.zero
            newValue.layer.shadowRadius = 5
            newValue.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20.0)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupTitle
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.label.color
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupMessage
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var actionButton: RoundedInsetsButton! {
        willSet {
            //newValue.insets = UIEdgeInsets(topBottom: 2.0, rightLeft: 48.0)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
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
