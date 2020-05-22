//
//  ContactSyncNoBackupView.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactSyncNoBackupViewDelegate: class {
    func didTouchBackupButton()
}


final class ContactSyncNoBackupView: UIView, NibInit {
    
    weak var delegate: ContactSyncNoBackupViewDelegate?
    

    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 24.0)
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupTitle
        }
    }
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 16.0)
            newValue.textColor = ColorConstants.charcoalGrey
            newValue.numberOfLines = 0
            newValue.textAlignment = .center
            newValue.text = TextConstants.contactSyncBackupMessage
        }
    }
    
    @IBOutlet private weak var actionButton: RoundedInsetsButton! {
        willSet {
            newValue.insets = UIEdgeInsets(topBottom: 2.0, rightLeft: 48.0)
            newValue.backgroundColor = ColorConstants.darkBlueColor
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.setTitle(TextConstants.contactSyncBackupButton, for: .normal)
        }
    }
    
    
    @IBAction private func backUp(_ sender: Any) {
        if let delegate = delegate {
            delegate.didTouchBackupButton()
        }
    }
}
